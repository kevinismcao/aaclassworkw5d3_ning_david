

require 'sqlite3'
require 'singleton'

class QuestionDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
   attr_accessor :fname, :lname, :id
   def self.find_by_id(id)
      user = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT 
         * 
      FROM 
         users 
      WHERE 
         id = ?
      SQL
      User.new(user.first)
   end

   def self.find_by_name(fname, lname)
      user = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT 
         * 
      FROM 
         users 
      WHERE 
         fname = ?
      AND
         lname = ?
      SQL
      User.new(user.first)
   end

   def initialize(options)
      @id = options['id']
      @fname = options['fname']
      @lname = options['lname']
   end

   def authored_questions
      Question.find_by_author_id(id)
   end

   def authored_replies
      Reply.find_by_replier_id(id)
   end
end

class Question
   attr_accessor :title, :body, :author_id
   def self.find_by_id(id)
      question = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT 
         * 
      FROM 
         questions 
      WHERE 
         id = ?
      SQL
      Question.new(question.first)
   end

   def self.find_by_author_id(author_id)
      user_questions = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT 
         * 
      FROM 
         questions
      WHERE 
         author_id = ?
      SQL
      return nil if user_questions.empty?
      user_questions.map{|ele| Question.new(ele)}
   end


   def initialize(options)
      @id = options['id']
      @title = options['title']
      @body = options['body']
      @author_id = options['author_id']
   end

   def author
      User.find_by_id(self.author_id)
   end

end

class Reply
   attr_accessor :id, :question_id, :parent_reply_id, :replier_id, :reply_body
   def self.find_by_replier_id(replier_id)
      user_replies = QuestionDatabase.instance.execute(<<-SQL, replier_id)
      SELECT 
         * 
      FROM 
         replies
      WHERE 
         replier_id = ?
      SQL
      return nil if user_replies.empty?
      user_replies.map{|ele| Reply.new(ele)}
   end

   def self.find_by_question_id(question_id)
      question_replies = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT 
         * 
      FROM 
         replies
      WHERE 
         question_id = ?
      SQL
      return nil if question_replies.empty?
      question_replies.map{|ele| Reply.new(ele)}
   end

   def initialize(options)
      @id = options['id']
      @question_id = options['question_id']
      @parent_reply_id = options['parent_reply_id']
      @replier_id = options['replier_id']
      @reply_body = options['reply_body']
   end
  
end

