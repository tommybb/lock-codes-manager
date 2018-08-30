require 'rails_helper'

feature 'reset or resend lock code to guest' do
  scenario 'non admin user is not able to reset/resend lock code' do
    user = create(:user, admin: false)
    guest = create(:guest, first_name: 'Tony', last_name: 'Stark')
    room = create(:room, number: 101, lock_uuid: '7551e1f1-ce76-4b10-a29c-327f9cf99587')
    create(:reservation, guest: guest, room: room, room_lock_pin_code: 1234)

    login_as user
    visit '/reservations'

    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101 1234')
      expect(page).not_to have_content('Resend code')
      expect(page).not_to have_content('Reset code')
    end
  end

  scenario 'admin is able to resend lock code' do
    stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/AC5a2dd5e841bc15cc2c010e2430ae326a/Messages.json").
      with(
        body: {"Body"=>"Hi Tony. You can access your room with 2389 code. Enjoy!",
               "From"=>"+15005550006",
               "To"=>"+48604633888"},
        ).to_return(status: 200, body: "", headers: {})

    admin = create(:user, admin: true)
    guest = create(:guest, first_name: 'Tony', last_name: 'Stark')
    room = create(:room, number: 101, lock_uuid: '7551e1f1-ce76-4b10-a29c-327f9cf99587')
    create(:reservation, guest: guest, room: room, room_lock_pin_code: 2389)

    login_as admin
    visit '/reservations'

    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101 2389')

      click_button 'Resend code'
    end
    expect(page).to have_content('Lock code has been successfully resent to guest.')
  end

  scenario 'admin is able to reset lock code' do
    stub_request(:get, "http://remotelockey.dev/locks/7551e1f1-ce76-4b10-a29c-327f9cf99587/refresh?x_api_key=5a0d40").
      to_return(status: 200, body: { pin: 6666 }.to_json)

    admin = create(:user, admin: true)
    guest = create(:guest, first_name: 'Tony', last_name: 'Stark')
    room = create(:room, number: 101, lock_uuid: '7551e1f1-ce76-4b10-a29c-327f9cf99587')
    create(:reservation, guest: guest, room: room, room_lock_pin_code: 2389)

    login_as admin
    visit '/reservations'

    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101 2389')

      click_button 'Reset code'
    end
    expect(page).to have_content('New pin code has been set!')
    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101 6666')
    end
  end

  scenario 'pin code is not set and admin gets info when request to RemoteLockey is unauthorized' do
    stub_request(:get, "http://remotelockey.dev/locks/7551e1f1-ce76-4b10-a29c-327f9cf99587/refresh?x_api_key=5a0d40").
      to_return(status: 401)

    admin = create(:user, admin: true)
    guest = create(:guest, first_name: 'Tony', last_name: 'Stark')
    room = create(:room, number: 101, lock_uuid: '7551e1f1-ce76-4b10-a29c-327f9cf99587')
    create(:reservation, guest: guest, room: room, room_lock_pin_code: 2389)

    login_as admin
    visit '/reservations'

    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101 2389')

      click_button 'Reset code'
    end
    expect(page).to have_content('New pin code has not been set! Something went wrong.')
    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101 2389')
    end
  end

  scenario 'pin code is not set and admin gets info when lock UUID is bad' do
    stub_request(:get, "http://remotelockey.dev/locks/7551e1f1-ce76-4b10-a29c-327f9cf99587/refresh?x_api_key=5a0d40").
      to_return(status: 403)

    admin = create(:user, admin: true)
    guest = create(:guest, first_name: 'Tony', last_name: 'Stark')
    room = create(:room, number: 101, lock_uuid: '7551e1f1-ce76-4b10-a29c-327f9cf99587')
    create(:reservation, guest: guest, room: room, room_lock_pin_code: 2389)

    login_as admin
    visit '/reservations'

    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101 2389')

      click_button 'Reset code'
    end
    expect(page).to have_content('New pin code has not been set! Something went wrong.')
    within('#reservations') do
      expect(page).to have_table_row_contents('Tony Stark 101 2389')
    end
  end
end
