class Admin::ProjectsController < Admin::ContentController
  private

  def kind = "project"

  def scope = Page.projects

  def starter_blocks
    %w[Client Location Year Scope].each_with_index.map { |label, i| { category: "fact", title: label, number: i } } +
      [{ category: "text", title: "The question", number: 4 }, { category: "text", title: "What we built", number: 5 }, { category: "text", title: "What we learned", number: 6 }]
  end
end
