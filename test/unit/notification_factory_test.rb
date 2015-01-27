# encoding: utf-8
require 'test_helper'

class NotificationFactoryTest < ActiveSupport::TestCase
  test 'notifications send' do
    result = NotificationFactory.send(
      :recipient    => User.find(2),
      :subject      => 'sime subject',
      :body         => 'some body',
      :content_type => '',
    )
    assert_match('some body', result.to_s)
    assert_match('text/plain', result.to_s)
    assert_no_match('text/html', result.to_s)

    result = NotificationFactory.send(
      :recipient    => User.find(2),
      :subject      => 'sime subject',
      :body         => 'some body',
      :content_type => 'text/plain',
    )
    assert_match('some body', result.to_s)
    assert_match('text/plain', result.to_s)
    assert_no_match('text/html', result.to_s)

    result = NotificationFactory.send(
      :recipient    => User.find(2),
      :subject      => 'sime subject',
      :body         => 'some <span>body</span>',
      :content_type => 'text/html',
    )
    assert_match('some body', result.to_s)
    assert_match('text/plain', result.to_s)
    assert_match('<span>body</span>', result.to_s)
    assert_match('text/html', result.to_s)
  end

  test 'notifications base' do
    ticket = Ticket.create(
      :title         => 'some title äöüß',
      :group         => Group.lookup( :name => 'Users'),
      :customer_id   => 2,
      :state         => Ticket::State.lookup( :name => 'new' ),
      :priority      => Ticket::Priority.lookup( :name => '2 normal' ),
      :updated_by_id => 2,
      :created_by_id => 2,
    )
    article_plain = Ticket::Article.create(
      :ticket_id     => ticket.id,
      :type_id       => Ticket::Article::Type.where(:name => 'phone' ).first.id,
      :sender_id     => Ticket::Article::Sender.where(:name => 'Customer' ).first.id,
      :from          => 'Zammad Feedback <feedback@example.org>',
      :body          => 'some text',
      :internal      => false,
      :updated_by_id => 1,
      :created_by_id => 1,
    )
    tests = [
      {
        :locale => 'en',
        :string => 'Hi #{recipient.firstname},',
        :result => 'Hi Nicole,',
      },
      {
        :locale => 'de',
        :string => 'Hi #{recipient.firstname},',
        :result => 'Hi Nicole,',
      },
      {
        :locale => 'de',
        :string => 'Hi #{recipient.firstname}, Group: #{ticket.group.name}',
        :result => 'Hi Nicole, Group: Users',
      },
      {
        :locale => 'de',
        :string => '#{config.http_type} some text',
        :result => 'http some text',
      },
      {
        :locale => 'de',
        :string => 'i18n(New) some text',
        :result => 'Neu some text',
      },
      {
        :locale => 'de',
        :string => '\'i18n(#{ticket.state.name})\' ticket state',
        :result => '\'neu\' ticket state',
      },
      {
        :locale => 'de',
        :string => 'a #{not_existing_object.test}',
        :result => 'a #{not_existing_object / no such object}',
      },
      {
        :locale => 'de',
        :string => 'a #{ticket.level1}',
        :result => 'a #{ticket.level1 / no such method}',
      },
      {
        :locale => 'de',
        :string => 'a #{ticket.level1.level2}',
        :result => 'a #{ticket.level1 / no such method}',
      },
      {
        :locale => 'de',
        :string => 'a #{ticket.title.level2}',
        :result => 'a #{ticket.title.level2 / no such method}',
      },
      {
        :locale => 'de',
        :string => 'by #{ticket.updated_by.fullname}',
        :result => 'by Nicole Braun',
      },
      {
        :locale => 'de',
        :string => 'Subject #{article.from}, Group: #{ticket.group.name}',
        :result => 'Subject Zammad Feedback <feedback@example.org>, Group: Users',
      },
      {
        :locale => 'de',
        :string => 'Body #{article.body}, Group: #{ticket.group.name}',
        :result => 'Body some text, Group: Users',
      },
      {
        :locale => 'de',
        :string => '\#{puts `ls`}',
        :result => '\#{puts `ls`} (not allowed)',
      },
    ]
    tests.each { |test|
      result = NotificationFactory.build(
        :string  => test[:string],
        :objects => {
          :ticket    => ticket,
          :article   => article_plain,
          :recipient => User.find(2),
        },
        :locale  => test[:locale]
      )
      assert_equal( test[:result], result, "verify result" )
    }

    ticket.destroy
  end

  test 'notifications html' do
    ticket = Ticket.create(
      :title         => 'some title <b>äöüß</b> 2',
      :group         => Group.lookup( :name => 'Users'),
      :customer_id   => 2,
      :state         => Ticket::State.lookup( :name => 'new' ),
      :priority      => Ticket::Priority.lookup( :name => '2 normal' ),
      :updated_by_id => 1,
      :created_by_id => 1,
    )
    article_html = Ticket::Article.create(
      :ticket_id     => ticket.id,
      :type_id       => Ticket::Article::Type.where(:name => 'phone' ).first.id,
      :sender_id     => Ticket::Article::Sender.where(:name => 'Customer' ).first.id,
      :from          => 'Zammad Feedback <feedback@example.org>',
      :body          => 'some <b>text</b><br>next line',
      :content_type  => 'text/html',
      :internal      => false,
      :updated_by_id => 1,
      :created_by_id => 1,
    )
    tests = [
      {
        :locale => 'de',
        :string => 'Subject #{ticket.title}',
        :result => 'Subject some title <b>äöüß</b> 2',
      },
      {
        :locale => 'de',
        :string => 'Subject #{article.from}, Group: #{ticket.group.name}',
        :result => 'Subject Zammad Feedback <feedback@example.org>, Group: Users',
      },
      {
        :locale => 'de',
        :string => 'Body #{article.body}, Group: #{ticket.group.name}',
        :result => 'Body some text
next line, Group: Users',
      },
    ]
    tests.each { |test|
      result = NotificationFactory.build(
        :string  => test[:string],
        :objects => {
          :ticket    => ticket,
          :article   => article_html,
          :recipient => User.find(2),
        },
        :locale  => test[:locale]
      )
      assert_equal( test[:result], result, "verify result" )
    }

    ticket.destroy
  end

  test 'notifications attack' do
    ticket = Ticket.create(
      :title         => 'some title <b>äöüß</b> 3',
      :group         => Group.lookup( :name => 'Users'),
      :customer_id   => 2,
      :state         => Ticket::State.lookup( :name => 'new' ),
      :priority      => Ticket::Priority.lookup( :name => '2 normal' ),
      :updated_by_id => 1,
      :created_by_id => 1,
    )
    article_html = Ticket::Article.create(
      :ticket_id     => ticket.id,
      :type_id       => Ticket::Article::Type.where(:name => 'phone' ).first.id,
      :sender_id     => Ticket::Article::Sender.where(:name => 'Customer' ).first.id,
      :from          => 'Zammad Feedback <feedback@example.org>',
      :body          => 'some <b>text</b><br>next line',
      :content_type  => 'text/html',
      :internal      => false,
      :updated_by_id => 1,
      :created_by_id => 1,
    )
    tests = [
      {
        :locale => 'de',
        :string => '\#{puts `ls`}',
        :result => '\#{puts `ls`} (not allowed)',
      },
      {
        :locale => 'de',
        :string => 'attack#1 #{article.destroy}',
        :result => 'attack#1 #{article.destroy} (not allowed)',
      },
      {
        :locale => 'de',
        :string => 'attack#2 #{Article.where}',
        :result => 'attack#2 #{Article.where} (not allowed)',
      },
      {
        :locale => 'de',
        :string => 'attack#1 #{article.
        destroy}',
        :result => 'attack#1 #{article.
        destroy} (not allowed)',
      },
      {
        :locale => 'de',
        :string => 'attack#1 #{article.find}',
        :result => 'attack#1 #{article.find} (not allowed)',
      },
      {
        :locale => 'de',
        :string => 'attack#1 #{article.update(:name => "test")}',
        :result => 'attack#1 #{article.update(:name => "test")} (not allowed)',
      },
      {
        :locale => 'de',
        :string => 'attack#1 #{article.all}',
        :result => 'attack#1 #{article.all} (not allowed)',
      },
      {
        :locale => 'de',
        :string => 'attack#1 #{article.delete}',
        :result => 'attack#1 #{article.delete} (not allowed)',
      },
    ]
    tests.each { |test|
      result = NotificationFactory.build(
        :string  => test[:string],
        :objects => {
          :ticket    => ticket,
          :article   => article_html,
          :recipient => User.find(2),
        },
        :locale  => test[:locale]
      )
      assert_equal( test[:result], result, "verify result" )
    }

    ticket.destroy
  end
end