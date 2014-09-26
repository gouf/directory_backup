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

  context '#add_targets' do
    it 'returns path array' do
      targets = %w(file0 file1 file1 file2)
      result = subject.add_targets(targets)

      expect(result.size).to eq 4
      expect(result.to_s).to match(/file0/)
      expect(result.to_s).to match(/file1/)
      expect(result.to_s).to match(/file2/)
    end
  end
end
