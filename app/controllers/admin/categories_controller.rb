class Admin::CategoriesController < Admin::AdminController
  def index
    begin
      Category.pull_categories
    rescue StandardError
      flash['alert'] = 'Falha ao atualizar categorias! Se alguma categoria não aparecer, tente novamente mais tarde'
    end
    @categories = Category.all.active
  end

  def new
    @category = Category.new
  end

  def create
    category_params = params.permit(:name)
    @category = Category.new(category_params)
    if @category.save
      flash['notice'] = 'Categoria cadastrada com sucesso!'
      return redirect_to admin_categories_path
    end
    flash.now['alert'] = 'Não foi possível salvar categoria'
    render 'new'
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    category_params = params.permit(:name)
    if @category.update(category_params)
      flash['notice'] = 'Categoria alterada com sucesso!'
      return redirect_to admin_categories_path
    end
    flash.now['alert'] = 'Não foi possível editar categoria'
    render 'new'
  end

  def destroy
    @category = Category.find(params[:id])
    @category.inactive!
    redirect_to admin_categories_path, notice: 'Categoria excluída com sucesso'
  end
end
