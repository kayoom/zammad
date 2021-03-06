# encoding: utf-8
require 'test_helper'

class SessionBasicTicketTest < ActiveSupport::TestCase

  test 'b ticket_overview_List' do
    UserInfo.current_user_id = 1
    Ticket.destroy_all

    # create users
    roles  = Role.where(name: ['Agent'])
    groups = Group.all

    agent1 = User.create_or_update(
      login: 'session-basic-ticket-agent-1',
      firstname: 'Session',
      lastname: 'session basic ' + rand(99_999).to_s,
      email: 'session-basic-ticket-agent-1@example.com',
      password: 'agentpw',
      active: true,
      roles: roles,
      groups: groups,
    )

    agent1.roles = roles
    assert(agent1.save, 'create/update agent1')

    Ticket.create(title: 'default overview test', group_id: 1, priority_id: 1, state_id: 1, customer_id: 1)

    user = User.lookup(id: agent1.id)
    client1 = Sessions::Backend::TicketOverviewList.new(user, {}, false, '123-1', 2)

    result1 = client1.push
    assert(result1, 'check ticket_overview_List')

    # next check should be empty / no changes
    result1 = client1.push
    assert(!result1, 'check ticket_overview_index - recall')

    # next check should be empty / no changes
    sleep 3
    result1 = client1.push
    assert(!result1, 'check ticket_overview_index - recall 2')

    # create ticket
    ticket = Ticket.create(title: '12323', group_id: 1, priority_id: 1, state_id: 1, customer_id: 1)
    sleep 3

    result1 = client1.push
    assert(result1, 'check ticket_overview_index - recall 3')
    sleep 3

    # chnage overview
    overviews = Ticket::Overviews.all(
      current_user: user,
    )
    overviews.first.touch

    result1 = client1.push
    assert(result1, 'check ticket_overview_index - recall 4')

    result1 = client1.push
    assert(!result1, 'check ticket_overview_index - recall 5')

    Sessions::Backend::TicketOverviewList.reset(user.id)
    result1 = client1.push
    assert(!result1, 'check ticket_overview_index - recall 6')

    ticket = Ticket.create(title: '12323 - 2', group_id: 1, priority_id: 1, state_id: 1, customer_id: 1)
    Sessions::Backend::TicketOverviewList.reset(user.id)
    result1 = client1.push
    assert(result1, 'check ticket_overview_index - recall 7')

  end

end
