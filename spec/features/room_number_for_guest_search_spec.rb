require 'rails_helper'

feature 'room number for guest search' do
  scenario 'user is able to find out in which room number given guest stays/will stay', type: :feature do
    user = create(:user)
    guest = create(:guest, first_name: 'Tony', last_name: 'Stark')
    room = create(:room, number: 101)
    create(:reservation, guest: guest, room: room)
    guest_2 = create(:guest, first_name: 'Mark', last_name: 'Dale')
    room_2 = create(:room, number: 102)
    create(:reservation, guest: guest_2, room: room_2)

    login_as user
    visit '/reservations'
    fill_in 'Guest First name equals', with: 'Tony'
    fill_in 'Guest Last name equals', with: 'Stark'
    click_button 'Search'

    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101')
      expect(page).not_to have_table_row_contents('Mark Dale 102')
    end
  end
end
