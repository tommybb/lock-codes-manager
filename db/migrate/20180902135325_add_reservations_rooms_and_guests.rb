class AddReservationsRoomsAndGuests < ActiveRecord::Migration[5.1]
  def change
    create_table :guests do |t|
      t.integer :roomy_id, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number, null: false
      t.string :email, null: false

      t.timestamps
    end

    create_table :rooms do |t|
      t.integer :roomy_id, null: false
      t.integer :number, null: false
      t.string :lock_uuid

      t.timestamps
    end

    create_table :reservations do |t|
      t.integer :roomy_id, null: false
      t.references :guest, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.date :checkin_date, null: false
      t.date :checkout_date, null: false
      t.datetime :booked_at, null: false
      t.integer :room_lock_pin_code
      t.boolean :cancelled, null: false, default: false

      t.timestamps
    end
  end
end
