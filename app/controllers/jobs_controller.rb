# Copyright (C) 2012-2014 Zammad Foundation, http://zammad-foundation.org/

class JobsController < ApplicationController
  before_filter :authentication_check

  def index
    return if deny_if_not_role('Admin')
    model_index_render(Job, params)
  end

  def show
    return if deny_if_not_role('Admin')
    model_show_render(Job, params)
  end

  def create
    return if deny_if_not_role('Admin')
    model_create_render(Job, params)
  end

  def update
    return if deny_if_not_role('Admin')
    model_update_render(Job, params)
  end

  def destroy
    return if deny_if_not_role('Admin')
    model_destory_render(Job, params)
  end
end