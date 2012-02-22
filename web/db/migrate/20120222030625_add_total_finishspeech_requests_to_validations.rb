class AddTotalFinishspeechRequestsToValidations < ActiveRecord::Migration
  def change
    add_column :validations, :total_finishspeech_requests, :integer,:default => 0
    add_column :validations, :total_tokens_recieved, :integer,:default => 0

  end
end
