require 'dbi'
RubyInstaller::Runtime.add_dll_directory("dll_lib/")

module TBD
    class Connect
        def self.connect_to_sql
            puts "connecting to sql..."
        end
    end
    class OracleConnector
        def self.open(database, username, password)
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
    end
end