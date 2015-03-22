# encoding: utf-8
require 'integration_test_helper'

class UserAgentTest < ActiveSupport::TestCase
  host = 'http://127.0.0.1:3003'

  # check
  test 'check some results' do

    # get / 200
    result = UserAgent.get(
      "#{host}/test/get/1?submitted=123",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"123"/)

    # get / 404
    result = UserAgent.get(
      "#{host}/test/not_existing",
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)

    # post / 200
    result = UserAgent.post(
      "#{host}/test/post/1",
      {
        :submitted => 'some value',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"post"/)
    assert(result.body =~ /"some value"/)

    # post / 404
    result = UserAgent.post(
      "#{host}/test/not_existing",
      {
        :submitted => 'some value',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)

    # put / 200
    result = UserAgent.put(
      "#{host}/test/put/1",
      {
        :submitted => 'some value',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"put"/)
    assert(result.body =~ /"some value"/)

    # put / 404
    result = UserAgent.put(
      "#{host}/test/not_existing",
      {
        :submitted => 'some value',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)

    # delete / 200
    result = UserAgent.delete(
      "#{host}/test/delete/1",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"delete"/)

    # delete / 404
    result = UserAgent.delete(
      "#{host}/test/not_existing",
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('404', result.code)
    assert_equal(NilClass, result.body.class)



    # with http basic auth

    # get / 200
    result = UserAgent.get(
      "#{host}/test_basic_auth/get/1?submitted=123",
      {
        :user     => 'basic_auth_user',
        :password => 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"123"/)

    # get / 401
    result = UserAgent.get(
      "#{host}/test_basic_auth/get/1?submitted=123",
      {
        :user     => 'basic_auth_user_not_existing',
        :password => 'test<>123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal(NilClass, result.body.class)

    # post / 200
    result = UserAgent.post(
      "#{host}/test_basic_auth/post/1",
      {
        :submitted => 'some value',
      },
      {
        :user     => 'basic_auth_user',
        :password => 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"post"/)
    assert(result.body =~ /"some value"/)

    # post / 401
    result = UserAgent.post(
      "#{host}/test_basic_auth/post/1",
      {
        :submitted => 'some value',
      },
      {
        :user     => 'basic_auth_user_not_existing',
        :password => 'test<>123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal(NilClass, result.body.class)

    # put / 200
    result = UserAgent.put(
      "#{host}/test_basic_auth/put/1",
      {
        :submitted => 'some value',
      },
      {
        :user     => 'basic_auth_user',
        :password => 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"put"/)
    assert(result.body =~ /"some value"/)

    # put / 401
    result = UserAgent.put(
      "#{host}/test_basic_auth/put/1",
      {
        :submitted => 'some value',
      },
      {
        :user     => 'basic_auth_user_not_existing',
        :password => 'test<>123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal(NilClass, result.body.class)


    # delete / 200
    result = UserAgent.delete(
      "#{host}/test_basic_auth/delete/1",
      {
        :user     => 'basic_auth_user',
        :password => 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"delete"/)

    # delete / 401
    result = UserAgent.delete(
      "#{host}/test_basic_auth/delete/1",
      {
        :user     => 'basic_auth_user_not_existing',
        :password => 'test<>123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal(NilClass, result.body.class)
  end

  # check
  test 'check redirect' do

    # get / 301
    result = UserAgent.request(
      "#{host}/test/redirect",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"abc"/)


    # get / 301
    result = UserAgent.request(
      "#{host}/test_basic_auth/redirect",
      {
        :user     => 'basic_auth_user',
        :password => 'test123',
      }
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"abc"/)


    # get / 401
    result = UserAgent.request(
      "#{host}/test_basic_auth/redirect",
      {
        :user     => 'basic_auth_user_not_existing',
        :password => 'test123',
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('401', result.code)
    assert_equal(NilClass, result.body.class)
  end

  # check
  test 'check request' do

    # get / 200
    result = UserAgent.request(
      "#{host}/test/get/1?submitted=123",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"get"/)
    assert(result.body =~ /"123"/)

    # ftp / 200
    result = UserAgent.request(
      "ftp://ftp.gwdg.de/msgs/banner.msg",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /Gesellschaft/i)

    # ftp / 401
    result = UserAgent.request(
      "ftp://ftp.gwdg.de/msgs/not_existing.msg",
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal('550', result.code)
    assert_equal(NilClass, result.body.class)

    # get / 200 / gzip
    result = UserAgent.request(
      "https://httpbin.org/gzip",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"GET"/)

    # get / 200 / gzip
    result = UserAgent.request(
      "http://httpbin.org/gzip",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"GET"/)

    # get / 200 / gzip
    result = UserAgent.request(
      "https://httpbin.org/deflate",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"GET"/)

    # get / 200 / gzip
    result = UserAgent.request(
      "http://httpbin.org/deflate",
    )
    assert(result)
    assert_equal(true, result.success?)
    assert_equal('200', result.code)
    assert_equal(String, result.body.class)
    assert(result.body =~ /"GET"/)

  end


  # check
  test 'check not existing' do

    # get / 0
    result = UserAgent.request(
      "http://not.existing.host/test.php",
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal(0, result.code)
    assert_equal(NilClass, result.body.class)

    # ftp / 0
    result = UserAgent.request(
      "ftp://not.existing.host/test.bin",
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal(0, result.code)
    assert_equal(NilClass, result.body.class)
  end


  # check
  test 'check timeout' do

    # get / timeout
    result = UserAgent.get(
      "#{host}/test/get/3?submitted=123",
      {
        :open_timeout => 1,
        :read_timeout => 1,
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal(0, result.code)
    assert_equal(NilClass, result.body.class)

    # post / timeout
    result = UserAgent.post(
      "#{host}/test/post/3",
      {
        :submitted => 'timeout',
      },
      {
        :open_timeout => 1,
        :read_timeout => 1,
      }
    )
    assert(result)
    assert_equal(false, result.success?)
    assert_equal(0, result.code)
    assert_equal(NilClass, result.body.class)
  end

end