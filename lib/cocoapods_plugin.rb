require 'cocoapods'
require 'xcodeproj'

def build_phase_by_name(target, name)
	target.build_phases.select { |p|
		next unless p.methods.include? :name
		p.name == name }.first
end

# TODO: Remove Pods_*.framework from Frameworks group
# TODO: Remove Pods_*.framework from Linked Frameworks
# TODO: Code-sign frameworks on copy
# TODO: Copy destination should be frameworks

# FIXME: For this to actually work, #3550 needs to be done ("Copy Frameworks" doesn't support scoping)

def integrate_target(target)
	project = Xcodeproj::Project.open(target.user_project_path)

	target.user_target_uuids.each do |uuid|
		user_target = project.targets.select { |t| t.uuid == uuid }.first
		frameworks_build_phase = user_target.frameworks_build_phase

		# Remove "Embed Pods Frameworks" build phase
		copy_frameworks_phase = build_phase_by_name(user_target, 'Embed Pods Frameworks')
		user_target.build_phases.delete(copy_frameworks_phase) if copy_frameworks_phase

		# Remove Pods framework dependencies
		frameworks_build_phase.files.select do |build_file|
		  build_file.display_name =~ /^(Pods*\.framework)$/i
		end.each { |build_file| frameworks_build_phase.remove_build_file(build_file) }

		# Embed Pods frameworks
		embed_frameworks_phase = build_phase_by_name(user_target, 'Embed Frameworks')
		if embed_frameworks_phase.nil?
			embed_frameworks_phase = user_target.new_copy_files_build_phase('Embed Frameworks')
			embed_frameworks_phase.dst_subfolder_spec = 'frameworks'
		end

		# Add explicit dependencies on Pods frameworks
		target.specs.each do |spec|
			build_phase = user_target.frameworks_build_phase
			frameworks = project.frameworks_group
			target_basename = spec.module_name

			new_product_ref = frameworks.files.find { |f| f.path == "#{target_basename}.framework" } ||
				frameworks.new_product_ref_for_target(target_basename, :framework)
			build_file = build_phase.build_file(new_product_ref) ||
				build_phase.add_file_reference(new_product_ref)

			embed_frameworks_phase.add_file_reference(new_product_ref)
		end
	end

	project.save
end

Pod::HooksManager.register('cocoapods-native-integration', :post_install) do |context, user_options|
	context.umbrella_targets.each do |target|
		integrate_target(target)
	end
end
