require 'dbi'
require 'base64'
require 'uri'
require 'httparty'
require 'OpenSSL'

# need to get the dll files

module TBD
    class Connect
        def self.test
            puts "testing..."
        end
    end
    class OracleConnector
        def self.open(database, username, password)
            # RubyInstaller::Runtime.add_dll_directory("#{__dir__}/dll_lib/")
            return DBI.connect("DBI:OCI8:#{database}", username, password)
        end
        def self.execute(dbh, sql)
            dbh.do(sql)
        end
        def self.select_query(dbh, sql)
            return dbh.select_one(sql)
        end
        def self.update_query(dbh, sql)
            update = dbh.prepare(sql)
            update.execute
            update.finish
            dbh.commit
        end
        def self.insert_query(dbh, sql)
            dbh.do(sql)
            dbh.commit
        end
        def self.delete_query(dbh, sql)
            dbh.execute(sql)
            dbh.commit
        end
        def self.rp_xml_blob_insert(dbh, pChannel, pForm, xml_doc)
            sth = dbh.prepare("INSERT INTO RP_XML_Forms (channel_source, submission_id, submission_type, submission_status, create_tmstmp, proc_begin_tmstmp, proc_end_tmstmp, xml_doc) VALUES (?, ?, ?, ?, ?, ?,?, EMPTY_BLOB())")
            sth.execute(pChannel, '', pForm, 'R', Time.now, '', '')
            row_id = sth.func(:rowid)
            puts row_id
            lob = dbh.select_one("SELECT xml_doc FROM RP_XML_Forms WHERE ROWID = ?", row_id)[0]
            lob.write(xml_doc)
            dbh.commit
            return row_id            
        end
        def self.validate_Table_Data(dbh, sql, expValue)
            (1..25).each do |i|
                sleep(2)
                record = dbh.select_one(sql)
                if !record.nil?
                    if record[0] == expValue
                        flag = true
                        break
                    end
                end
            end
            return flag
        end
        def self.validate_RP_Sub_Detail_Data(dbh, sql, expValue)
            (1..25).each do |i|
                sleep(2)
                if !record.nil?
                    if record[0] != expValue
                        flag = true
                        break
                    end
                end
            end
            return flag
        end
        def self.validate_table_entry(dbh, sql)
            (1..25).each do |i|
                sleep(2)
                record = dbh.select_one(sql)
                if !record.nil?
                    flag = true
                    break
                end
            end
            return flag
        end
        def self.close(dbh)
            dbh.disconnect
        end
    end
    class CosmosConnector
        def self.run_query(host, request, query_data)
            url = "#{host}/#{request}"
            auth_headers = get_auth_headers action: 'POST', request: request
            message_headers = {
                'Accept' => 'application/json',
                'x-ms-version' => '2016-07-11',
                'x-ms-documentdb-isquery' => 'true',
                'x-ms-max-item-count' => '-1',
                'Content-Type' => 'application/query+json',
                'x-ms-documentdb-query-enablecrosspartition' => 'true' 
            }
            message_headers['x-ms-date'] = auth_headers['x-ms-date']
            message_headers['Authorization'] = auth_headers['Authorization']
            response = HTTParty.post(url, body: query_data, headers: message_headers)
            process_response response
        end
        def self.get_auth_headers(input)
            request = input[:request]
            utc_string = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
            request_components = request.split('/')
            component_count = request_components.count-1
            resource_id = ''
            resource_type = ''
            if (component_count % 2)
                resource_type = request_components[component_count]
                if (component_count > 1)
                    resource_id = request[0..(request.rindex('/')-1)]
                end
            else
                resource_type = request_components[component_count-1]
                resource_id = request
            end
            if input[:action].nil?
                verb = 'get'
            else
                verb = input[:action].downcase
            end
            date = utc_string.downcase
            key = (Base64.decode64 @master_key)
            text = (verb || "").downcase + "\n" + (resource_type || "").downcase + "\n" + (date || "").downcase + "\n" + "" + "\n"
            signature = OpenSSL::HMAC.digest('SHA256',key,text)
            base_64_bits = (Base64.encode64 signature).chomp
            master_token = "master"
            token_version = "1.0"
            auth_string = "type=" + master_token + "&ver=" + token_version + "&sig=" + base_64_bits
            auth = URI.escape(auth_string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
            header = {
                "x-ms-date" => utc_string,
                "Authorization" => auth
            }
        end
        def self.process_response(response)
            unless response.code.eql? 200
                raise HTTParty::ResponseError, "#{response.code} - #{response.message}"
            end
            response.body
        end
    end
end