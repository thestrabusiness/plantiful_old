class ReminderMailer < ApplicationMailer
  def remind
    @user = params[:user]
    @plants_that_need_care = @user.actve_plants.need_care
    @sign_in_url = 'https://plantiful.herokuapp.com/sign_in'

    return unless @plants_that_need_care.present?

    mail(to: @user.email, subject: 'Give your plants some love!')
  end
end
