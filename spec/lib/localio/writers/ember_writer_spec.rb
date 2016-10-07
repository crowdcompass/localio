require 'spec_helper'

RSpec.describe EmberWriter do
  describe ".javascript_parsing" do
    it "inserts the correct string parameter notation" do
      string = "No search results in <s$1> for <s$2>"
      expect(described_class.javascript_parsing(string)).to eq "No search results in {1} for {2}"
    end

    it "inserts the correct digit parameter notation" do
      string = "<d$1> characters remaining of <d$2>"
      expect(described_class.javascript_parsing(string)).to eq "{1} characters remaining of {2}"
    end

    it "escapes triple quotes" do
      string = 'No search results in <s$1> for ""<s$2>""'
      expect(described_class.javascript_parsing(string)).to eq 'No search results in {1} for \"{2}\"'
    end
  end

  describe ".write" do
    it "should successfully run" do
      # supress writing out the translations to a file
      allow(TemplateHandler).to receive(:process_template).and_return(true)

      locfile = Locfile.new
      locfile.platform(:ember)
      locfile.source(:csv, path: "../../../spec/support/crowdcompass_localization_test.csv")
      locfile.languages([:en])

      localio_stdout = capture_stdout {
        Localio.from_configuration(locfile)
      }
      expect(localio_stdout).to include("Done!")
    end
  end
end
