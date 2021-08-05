require 'rails_helper'
require 'encryption_service'

describe EncryptionService do
  let(:plaintext) { 'secret' }
  let(:other_plaintext) { 'topsecret' }

  describe '.encrypt' do
    subject { EncryptionService.encrypt(plaintext) }

    it { is_expected.not_to eq(plaintext) }
    it { is_expected.not_to be_nil }
    it { is_expected.not_to eq(EncryptionService.encrypt(other_plaintext)) }

    context 'same plaintext' do
      it 'returns *different* ciphertext' do
        ciphertext1 = EncryptionService.encrypt(plaintext)
        ciphertext2 = EncryptionService.encrypt(plaintext)

        expect(ciphertext1).not_to eq(ciphertext2)
      end
    end

    context 'nil plaintext' do
      specify { expect(EncryptionService.encrypt(nil)).to be_nil }
    end

    context 'empty plaintext' do
      specify { expect(EncryptionService.encrypt('')).to be_nil }
    end
  end

  describe '.decrypt' do
    let(:ciphertext) { EncryptionService.encrypt(plaintext) }

    specify { expect(EncryptionService.decrypt(ciphertext)).to eq(plaintext) }

    context 'same plaintext twice' do
      it 'returns the same plaintext' do
        ciphertext1 = EncryptionService.encrypt(plaintext)
        ciphertext2 = EncryptionService.encrypt(plaintext)

        expect(ciphertext1).not_to eq(ciphertext2)

        plaintext1 = EncryptionService.decrypt(ciphertext1)
        plaintext2 = EncryptionService.decrypt(ciphertext2)

        expect([plaintext1, plaintext2]).to all eq(plaintext)
      end
    end

    context 'nil ciphertext' do
      specify { expect(EncryptionService.decrypt(nil)).to be_nil }
    end

    context 'empty ciphertext' do
      specify { expect(EncryptionService.decrypt('')).to be_nil }
    end
  end
end
