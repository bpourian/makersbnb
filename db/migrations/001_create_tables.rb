Sequel.migration do
  up do
    create_table?(:users) do
      primary_key :id
      String :username, size: 50, null: false, unique: true
      String :email, size: 50, null: false, unique: true
      String :password_hash, text: true, null: false
    end
    create_table?(:spaces) do
      primary_key :id
      String :space_name, size: 50, null: false
      String :space_description, text: true, null: false
      String :space_price, size: 50, null: false
      String :availability_start, size: 50, null: false
      String :availability_end, size: 50, null: false
      foreign_key :user_id, :users, null: false
    end
  end
end
