class AddTitleAndReleaseYearToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :title,        :string
    add_column :movies, :release_year, :integer
  end
end
