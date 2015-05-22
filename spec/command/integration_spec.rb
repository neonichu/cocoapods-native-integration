require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Integration do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ integration }).should.be.instance_of Command::Integration
      end
    end
  end
end

