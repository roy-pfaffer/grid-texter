migration "create the users table" do
  database.create_table :users do
    primary_key :id
    DateTime :created_at
    text :alias
    integer :sms_number
    boolean :active
  end
end

migration "create the messages table" do
  database.create_table :messages do
    primary_key :id
    text :content
    DateTime :created_at
  end
end
