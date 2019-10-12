require 'rails_helper'

RSpec.feature 'User adds a new garden' do
  context 'with a valid input' do
    it 'adds the new garden' do
      user = create(:user)
      existing_garden = user.owned_gardens.first
      visit garden_path(existing_garden, user)

      find('.menu__button').click
      find('.menu__button--add-garden').click
      fill_in 'Add a new garden', with: 'New Garden'
      click_button 'Submit'

      within '.menu' do
        expect(page).to have_content 'New Garden'
      end
    end

    it 'redirects the user to the garden\'s plant list' do
      user = create(:user)
      existing_garden = user.owned_gardens.first
      visit garden_path(existing_garden, user)

      find('.menu__button').click
      find('.menu__button--add-garden').click
      fill_in 'Add a new garden', with: 'New Garden'
      click_button 'Submit'

      new_garden_id = Garden.last.id
      expect(page).to have_current_path("/gardens/#{new_garden_id}")
    end
  end

  context 'with an invalid input' do
    it 'renders a validation error' do
      user = create(:user)
      existing_garden = user.owned_gardens.first
      visit garden_path(existing_garden, user)

      find('.menu__button').click
      find('.menu__button--add-garden').click
      click_button 'Submit'

      expect(page).to have_content 'You must provide a name'
    end
  end
end
