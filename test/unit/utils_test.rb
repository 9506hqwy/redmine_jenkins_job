# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class UtilsTest < ActiveSupport::TestCase
  def test_rel_path_01
    r = RedmineJenkinsJob::Utils.rel_path('https://127.0.0.1/', 'https://127.0.0.1/')
    assert_equal '/',  r
  end

  def test_rel_path_02
    r = RedmineJenkinsJob::Utils.rel_path('https://127.0.0.1/a', 'https://127.0.0.1/')
    assert_equal 'a/',  r
  end

  def test_rel_path_03
    r = RedmineJenkinsJob::Utils.rel_path('https://127.0.0.1/a/', 'https://127.0.0.1/')
    assert_equal 'a/',  r
  end

  def test_rel_path_04
    r = RedmineJenkinsJob::Utils.rel_path('https://127.0.0.1/', 'https://127.0.0.1')
    assert_equal '/',  r
  end

  def test_rel_path_05
    r = RedmineJenkinsJob::Utils.rel_path('https://127.0.0.1/a', 'https://127.0.0.1')
    assert_equal 'a/',  r
  end

  def test_rel_path_06
    r = RedmineJenkinsJob::Utils.rel_path('https://127.0.0.1/a/', 'https://127.0.0.1')
    assert_equal 'a/',  r
  end
end
