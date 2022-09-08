# frozen_string_literal: true

RSpec.describe IsDayOff do
  let(:store) { instance_double(storeKlass, :[] => days) }
  let(:storeKlass) { "#{described_class}::Store" }

  before do
    stub_const(storeKlass, class_double(storeKlass, new: store))
    described_class.clear_store!
  end

  shared_examples "checks 'date' argument" do
    it "raises error" do
      expect { f.call("2022-10-25") }.to raise_error(ArgumentError, "'date' argument must be a Date")
    end
  end

  shared_examples "raises store no data" do
    let(:days) { nil }

    it "raises error" do
      expect { f.call(Date.new(2022, 10, 25)) }.to raise_error(described_class::NoDataError) { |error|
        expect(error.message).to eq("No dayoff.ru data for given date")
        expect(error.date).to eq(Date.new(2022, 10, 25))
      }
    end
  end

  describe ".day_code" do
    subject(:f) { described_class.method(:day_code) }

    let(:days) { "01234" * 15 }

    it { expect(f.call(Date.new(2022, 1, 1))).to eq("0") }
    it { expect(f.call(Date.new(2022, 1, 3))).to eq("2") }
    it { expect(f.call(Date.new(2022, 1, 6))).to eq("0") }
    it { expect(f.call(Date.new(2022, 3, 1))).to eq("4") }

    it_behaves_like "checks 'date' argument"
    it_behaves_like "raises store no data"
  end

  describe ".workday?" do
    subject(:f) { described_class.method(:workday?) }

    let(:days) { "01001" * 15 }

    it { expect(f.call(Date.new(2022, 1, 1))).to be_truthy }
    it { expect(f.call(Date.new(2022, 1, 2))).to be_falsey }
    it { expect(f.call(Date.new(2022, 1, 3))).to be_truthy }
    it { expect(f.call(Date.new(2022, 1, 6))).to be_truthy }
    it { expect(f.call(Date.new(2022, 3, 1))).to be_falsey }

    it_behaves_like "checks 'date' argument"
    it_behaves_like "raises store no data"
  end

  describe ".holiday?" do
    subject(:f) { described_class.method(:holiday?) }

    let(:days) { "01001" * 15 }

    it { expect(f.call(Date.new(2022, 1, 1))).to_not be_truthy }
    it { expect(f.call(Date.new(2022, 1, 2))).to_not be_falsey }
    it { expect(f.call(Date.new(2022, 1, 3))).to_not be_truthy }
    it { expect(f.call(Date.new(2022, 1, 6))).to_not be_truthy }
    it { expect(f.call(Date.new(2022, 3, 1))).to_not be_falsey }

    it_behaves_like "checks 'date' argument"
    it_behaves_like "raises store no data"
  end

  describe ".forward_to_workday" do
    subject(:f) { described_class.method(:forward_to_workday) }

    let(:days) { "0011100001" * 10 }

    it { expect(f.call(Date.new(2022, 1, 1))).to eq(Date.new(2022, 1, 1)) }
    it { expect(f.call(Date.new(2022, 1, 2))).to eq(Date.new(2022, 1, 2)) }
    it { expect(f.call(Date.new(2022, 1, 3))).to eq(Date.new(2022, 1, 6)) }
    it { expect(f.call(Date.new(2022, 1, 4))).to eq(Date.new(2022, 1, 6)) }
    it { expect(f.call(Date.new(2022, 1, 5))).to eq(Date.new(2022, 1, 6)) }
    it { expect(f.call(Date.new(2022, 1, 6))).to eq(Date.new(2022, 1, 6)) }
    it { expect(f.call(Date.new(2022, 3, 1))).to eq(Date.new(2022, 3, 2)) }

    it_behaves_like "checks 'date' argument"
    it_behaves_like "raises store no data"
  end
end
