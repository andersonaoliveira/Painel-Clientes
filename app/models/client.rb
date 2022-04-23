class Client < ApplicationRecord
  has_many :products, dependent: :nullify
  has_many :orders, dependent: :nullify
  has_many :service_desks, dependent: :nullify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, :eni, presence: true
  validates :eni, uniqueness: true
  validate :eni_length

  private

  def eni_length
    return if eni.length == 11 || eni.length == 14

    errors.add :base, 'documento não possui o tamanho esperado (11 ou 14 caracteres)'
  end
end
