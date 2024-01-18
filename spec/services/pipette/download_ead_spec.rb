# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pipette::DownloadEad do
  include Pipette::DownloadEad
  # include FakeFS::SpecHelpers

  let(:aspace_id) { 123 }
  let(:resource_xml) do
    <<~EOS
      <ead>
        <eadheader>
          <eadid>1234</eadid>
        </eadheader>
          <archdesc level="1">
            <did>
              <unittitle>title</unittitle>
            </did>
          </archdesc>
      </ead>
    EOS
  end
  let(:download_dir) { Dir.mktmpdir }
  let(:download_dir_path) { download_dir.to_s }
  let(:pdf_dir) { Dir.mktmpdir }
  let(:pdf_dir_path) { pdf_dir.to_s }

  around do |example|
    ENV['FINDING_AID_DATA'] = download_dir_path
    ENV['FINDING_AID_PDF_PATH'] = pdf_dir_path
    example.run
  end

  after do
    FileUtils.rm_rf(download_dir)
    FileUtils.rm_rf(pdf_dir)
  end

  it 'writes downloaded XML' do
    file_written?
  end

  it 'deletes downloaded XML and the generated PDF' do
    file_written?
    pdf_path = "#{pdf_dir_path}/ncc/1234.pdf"
    Dir.mkdir("#{pdf_dir_path}/ncc")
    File.open(pdf_path, 'w') { |file| file.write("EAD PDF") }
    expect(File.exist?(pdf_path)).to be_truthy

    delete_xml('1234', 'ncc')
    expect(File.exist?("#{download_dir_path}/ncc/1234.xml")).to be_falsey
    expect(File.exist?(pdf_path)).to be_falsey
  end

  def file_written?
    write_xml('1234', 'ncc', resource_xml)
    expect(File.read("#{download_dir_path}/ncc/1234.xml")).to eq resource_xml
  end
end