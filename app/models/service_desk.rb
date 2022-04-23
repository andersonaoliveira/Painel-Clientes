class ServiceDesk < ApplicationRecord
  belongs_to :category
  belongs_to :client
  belongs_to :admin, optional: true
  belongs_to :order, optional: true
  has_many :messages, dependent: :nullify
  validates :description, presence: true

  enum status: { open: 0, in_progress: 1, wait_approval_client: 2, closed: 3 }

  STATUS = [
    ['Status', nil],
    ['Aberto', 0],
    ['Em Andamento', 1],
    ['Aguardando Resposta do Cliente', 2],
    ['Fechado', 3]
  ].freeze

  def self.status
    STATUS
  end

  def created
    created_at.strftime('%d/%m/%Y')
  end

  def closed
    updated_at.strftime('%d/%m/%Y')
  end
end
