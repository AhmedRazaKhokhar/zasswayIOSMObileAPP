CREATE TABLE messages (ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
                       remote_id INTEGER,
                       date_sent INTEGER,
                       date_received INTEGER,
                       mailbox INTEGER,
                       remote_mailbox INTEGER,
                       original_mailbox INTEGER,
                       flags INTEGER,
                       read,
                       flagged,
                       deleted,
                       visible,
                       sender_vip,
                       size INTEGER,
                       encoding,
                       content_type,
                       message_id INTEGER,
                       conversation_id INTEGER,
                       sequence_identifier INTEGER DEFAULT 0,
                       external_id TEXT,
                       unique_id INTEGER,
                       content_index_transaction_id INTEGER,
                       list_id_hash INTEGER);

CREATE INDEX date_index ON messages(date_received);
CREATE INDEX message_infos_index ON messages(mailbox, deleted, sender_vip, flags, conversation_id, date_sent, message_id, date_received DESC, ROWID DESC);
CREATE INDEX message_visible_index ON messages(mailbox, visible, date_received DESC, ROWID DESC);
CREATE INDEX message_remote_mailbox_index ON messages(remote_mailbox, remote_id);
CREATE INDEX message_message_id_index ON messages(message_id);
CREATE INDEX message_conversation_id_index ON messages(conversation_id, mailbox, read, date_received);
CREATE INDEX message_oldest_conversation_index on messages(mailbox, conversation_id, date_received);
CREATE INDEX message_content_index_transaction_id_index ON messages(content_index_transaction_id, deleted, date_received DESC, ROWID);
CREATE INDEX message_sequence_identifier_index ON messages(mailbox, remote_id, sequence_identifier);
CREATE INDEX message_mailbox_content_index ON messages (mailbox, content_index_transaction_id, flags, date_received ASC);
CREATE INDEX message_list_id_hash_index ON messages(list_id_hash);

CREATE TABLE IF NOT EXISTS categorization_sender_rules (sender TEXT PRIMARY KEY, category INT);
CREATE TABLE IF NOT EXISTS categorization_conversation_rules (conversation_id INT PRIMARY KEY, category INT);
CREATE TABLE IF NOT EXISTS categorization_group_rules (email TEXT PRIMARY KEY, category INT);

CREATE TABLE mailboxes (ROWID INTEGER PRIMARY KEY,
                        url UNIQUE,
                        sequence_identifier TEXT,
                        total_count INTEGER DEFAULT 0,
                        unread_count INTEGER DEFAULT 0,
                        deleted_count INTEGER DEFAULT 0,
                        flagged_count INTEGER DEFAULT 0,
                        attachment_count INTEGER DEFAULT 0,
                        to_cc_count INTEGER DEFAULT 0,
                        server_unread_count INTEGER DEFAULT 0,
                        last_sync_status_count INTEGER DEFAULT 0,
                        most_recent_status_count INTEGER DEFAULT 0,
                        reconcile);

CREATE TABLE threads (ROWID INTEGER PRIMARY KEY,
                      message_id INTEGER,
                      reference INTEGER,
                      is_originator);
CREATE INDEX references_mid_reference_index ON threads(message_id, reference);
CREATE INDEX references_reference_mid_index ON threads(reference, message_id);

CREATE TABLE conversations (conversation_id INTEGER PRIMARY KEY,
                            flags INTEGER DEFAULT 0,
                            sync_key TEXT);
                            
CREATE TABLE conversation_id_message_id (conversation_id INTEGER,
                                         message_id INTEGER,
                                         date_sent INTEGER DEFAULT 0,
                                         UNIQUE (conversation_id, message_id),
                                         FOREIGN KEY (conversation_id) REFERENCES conversations(conversation_id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE INDEX conversation_id_message_id_index ON conversation_id_message_id(conversation_id, message_id);
CREATE INDEX message_id_conversation_id_index ON conversation_id_message_id(message_id, conversation_id);

CREATE TABLE pop_uids(mailbox INTEGER,
                      uid TEXT,
                      date_added INTEGER,
                      flags, del, unique(mailbox, uid));
CREATE INDEX pop_uid_date_index ON pop_uids(mailbox, date_added);

CREATE TABLE message_data(ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
                          message_id INTEGER,
                          part,
                          partial,
                          complete,
                          length,
                          UNIQUE(message_id, part));
CREATE INDEX message_data_part_index ON message_data(message_id, part);

CREATE TABLE message_metadata(ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
                              message_id INTEGER,
                              key TEXT,
                              data);
CREATE UNIQUE INDEX message_metadata_key_index ON message_metadata(message_id, key);

CREATE TABLE properties (ROWID INTEGER PRIMARY KEY,
                         key,
                         value,
                         UNIQUE (key));
                         
CREATE TABLE messages_deleted (message_id INTEGER PRIMARY KEY);
CREATE TABLE message_data_deleted (message_data_id INTEGER PRIMARY KEY);
CREATE TABLE mbl_queue (message_id INTEGER PRIMARY KEY, FOREIGN KEY (message_id) REFERENCES messages(ROWID) ON DELETE CASCADE);

CREATE TABLE accounts (ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
                       text_id TEXT,
                       UNIQUE(text_id));
                       
CREATE TABLE offline_cache_operations (ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
                                       account_id INTEGER,
                                       completed,
                                       last_temporary_id INTEGER,
                                       operation_data);
CREATE INDEX offline_cache_operations_account_index ON offline_cache_operations(account_id, ROWID ASC);

CREATE TABLE offline_cache_replay_data (ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
                                        account_id INTEGER,
                                        replay_data);
CREATE INDEX offline_cache_replay_data_account_index ON offline_cache_operations(account_id, ROWID ASC);

CREATE TABLE spotlight_tombstones (ROWID INTEGER PRIMARY KEY AUTOINCREMENT,
                                   type INTEGER,
                                   identifier TEXT,
                                   transaction_id INTEGER,
                                   UNIQUE(type, identifier));
CREATE INDEX spotlight_tombstones_transaction_index ON spotlight_tombstones(transaction_id, type, identifier);

CREATE TABLE spotlight_message_reindex (message_id INTEGER,
                                        type INTEGER,
                                        UNIQUE(message_id),
                                        FOREIGN KEY (message_id) REFERENCES messages(ROWID) ON DELETE CASCADE);
CREATE INDEX spotlight_message_reindex_index ON spotlight_message_reindex(message_id, type);

