#
# Copyright 2015, SUSE Linux GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative "../../../spec_helper"

describe "Crowbar::Client::Filter::Subset" do
  subject { ::Crowbar::Client::Filter::Subset }

  let!(:values) do
    {
      id: "herbert",
      name: "Herbert",
      foo: {
        bar: {
          baz: "Hello"
        }
      },
      children: [
        {
          name: "Hans"
        },
        {
          name: "Olga"
        }
      ]
    }
  end

  context "with a defined filter" do
    it "limits the hash output" do
      instance = subject.new(
        values: values,
        filter: "foo.bar"
      )

      expect(
        instance.result
      ).to eq(values[:foo][:bar])
    end

    it "returns a nil value" do
      instance = subject.new(
        values: values,
        filter: "nothing"
      )

      expect(
        instance.result
      ).to eq(nil)
    end
  end

  context "without defined filter" do
    it "returns unfiltered values" do
      instance = subject.new(
        values: values
      )

      expect(
        instance.result
      ).to eq(values)
    end
  end
end
