#
# Copyright 2023- joao.limberger
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

require "fluent/plugin/output"

module Fluent
  module Plugin
    class FluentPluginAggregateByFieldOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("aggregate-by-field", self)
      
      # Enable threads if you are writing an async buffered plugin.
      helpers :thread
      
      # Define parameters for your plugin.
      config_param :key_name
      def start
        @waiting_ids_mutex = Mutex.new
        @waiting_ids = []
    
        timer_create(:awesome_delayed_checker, 5) do
          @waiting_ids_mutex.synchronize{ @waiting_ids.dup }.each do |chunk_id|
            if check_it_succeeded(chunk_id)
              commit_write(chunk_id)
              @waiting_ids_mutex.synchronize{ @waiting_ids.delete(chunk_id) }
            end
          end
        end
      end
      
      #### Async Buffered Output #############################   
      # chunk: a buffer chunk (Fluent::Plugin::Buffer::Chunk)
      def try_write(chunk)
        real_key_name = extract_placeholders(@key_name, chunk)
        log.debug 'sending data to server', chunk_id: dump_unique_id_hex(chunk.unique_id)
        log.debug 'key', real_key_name
        chunk_id = chunk.unique_id
        send_to_destination(chunk)
        @waiting_ids.synchronize{ @waiting_ids << chunk_id }
      end
    

  
      # Override `#format` if you want to customize how Fluentd stores
      # events. Read the section "How to Customize the Serialization
      # Format for Chunks" for details.
      # tag of events
      # time: a Fluent::EventTime object or an Integer representing Unix timestamp (seconds from Epoch) 
      # record: a Hash with String keys
      def format(tag, time, record)
        [tag, time, record].to_json
      end
    


    end
  end
end
