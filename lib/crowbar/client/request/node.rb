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

module Crowbar
  module Client
    class Request
      module Node
        extend ActiveSupport::Concern

        included do
          def node_action(action, name)
            result = self.class.get(
              "/crowbar/machines/1.0/#{action}/#{name}"
            )

            if block_given?
              yield result
            else
              result
            end
          end

          def node_transition(name, state)
            result = self.class.post(
              "/crowbar/crowbar/1.0/transition/default",
              body: {
                name: name,
                state: state
              }.to_json,
              headers: {
                "Content-Type" => "application/json"
              }
            )

            if block_given?
              yield result
            else
              result
            end
          end

          def node_rename(name, update)
            result = self.class.post(
              "/crowbar/machines/1.0/rename/#{name}",
              body: {
                alias: update
              }.to_json,
              headers: {
                "Content-Type" => "application/json"
              }
            )

            if block_given?
              yield result
            else
              result
            end
          end

          def node_role(name, update)
            result = self.class.post(
              "/crowbar/machines/1.0/role/#{name}",
              body: {
                role: update
              }.to_json,
              headers: {
                "Content-Type" => "application/json"
              }
            )

            if block_given?
              yield result
            else
              result
            end
          end

          def node_show(name)
            result = self.class.get(
              "/crowbar/machines/1.0/#{name}"
            )

            if block_given?
              yield result
            else
              result
            end
          end

          def node_delete(name)
            result = self.class.delete(
              "/crowbar/machines/1.0/#{name}"
            )

            if block_given?
              yield result
            else
              result
            end
          end

          def node_list
            result = self.class.get(
              "/crowbar/machines/1.0"
            )

            if block_given?
              yield result
            else
              result
            end
          end

          def node_status
            result = self.class.get(
              "/nodes/status"
            )

            if block_given?
              yield result
            else
              result
            end
          end
        end
      end
    end
  end
end
