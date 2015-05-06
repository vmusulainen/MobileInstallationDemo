require 'rho/rhocontroller'
require 'helpers/application_helper'
require 'helpers/browser_helper'

class HostController < Rho::RhoController
  include ApplicationHelper
  include BrowserHelper

  def index
    render
  end


  def sub_apps
    sub_apps_directory = File.join(Rho::Application.appBundleFolder, 'SubApps')

    unless File.exist?(sub_apps_directory)
      return []
    end

    fileEntries = Dir.entries(sub_apps_directory).select { |fname| fname != '.' && fname != '..' }
    sub_app_directories = fileEntries.select { |each| File.directory?(File.join(Rho::Application.appBundleFolder, 'SubApps', each)) }

    sub_apps = sub_app_directories.collect { |each|
      app_path = 'SubApps/' + each
      app_config_path = app_path, 'config.json'
      {:app_path => app_path, :app_config_path => app_config_path} }

    sub_apps.keep_if { |each|
      path = File.join(Rho::Application.appBundleFolder, each[:app_config_path])
      File.exist?(path) }

    i = 1
    sub_apps.each { |each|
      path = File.join(Rho::Application.appBundleFolder, each[:app_config_path])
      lines = File.read(path)
      json = Rho::JSON.parse(lines)
      each[:label] = json['label']
      each[:action] = json['startPath']
      each[:index] = i
      i = i + 1
    }
    return sub_apps
  end

  def tabbars

    tabbars = [{:label => 'Home', :action => url_for(:controller => :Host, :action => '/'), :reload => true}]
    sub_apps.each { |each|
      tabbars.push({:label => each[:label], :action => url_for(:controller => each[:app_path], :action => each[:action]), :reload => true});
    }
    return tabbars
  end

  def create_native_tabbar
    Rho::NativeTabbar.create(
        tabbars,
        {
            :createOnInit => false,
            :hiddenTabs => true
        })

  end

  def download
    url = 'http://127.0.0.1:8081/download'
    if !Rho::RhoSupport.rhobundle_download(url, url_for(:action => :download_callback))
      render :action => :error
    else
      render :action => :wait_download, :back => '/app'
    end
  end

  def download_callback
    if System.unzip_file(Rho::RhoSupport.rhobundle_getfilename())==0
      puts Rho::RhoSupport.rhobundle_getfilename()
      System.replace_current_bundle(File.dirname(Rho::RhoSupport.rhobundle_getfilename()), {:callback => url_for(:controller => :Host, :action => :install_callback), :do_not_restart_app => true})
      WebView.navigate url_for :action => :index
    else
      puts 'UNZIP ERROR'
      WebView.navigate url_for :action => :error
    end

  end

  def install_callback
    if @params["status"] == "ok"
      create_native_tabbar
      Rho::NativeTabbar.switchTab(0)
    else
      WebView.navigate url_for :action => :error
    end
  end

  def error
    render :error
  end

  def switchtab
    Rho::NativeTabbar.switchTab(@params['tab'].to_i)
  end

  def switchToHostApp
    Rho::NativeTabbar.switchTab(0)
  end


end
