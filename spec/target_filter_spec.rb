require_relative '../target_filter'

include TargetFilter
describe TargetFilter do

  subject { TargetFilter }

  context '#add_target' do
    it 'returns path array' do
      result = subject.add_target('./file')
      expect(result.class).to eq Array
      expect(result.to_s).to match(/.+file\"\]$/)
    end
  end
end
