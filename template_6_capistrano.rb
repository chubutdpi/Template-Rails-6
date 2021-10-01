#----------------------------------------------------------
########################## GEMAS ##########################
#----------------------------------------------------------

## Gema Usuarios, Roles y Permisos.
gem 'devise'
gem 'cancancan'
gem 'rolify'

## Gema para fuentes de iconos.
gem 'font-awesome-rails'

## Gema para administración.
gem 'rails_admin', '~> 2.0'

## Gema para control de cambios en la BD.
gem 'paper_trail'

## Gema para producción.
gem 'capistrano', '~> 3.11'
gem 'capistrano-rails', '~> 1.4'
gem 'capistrano-passenger', '~> 0.2.0'
gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.4'
gem 'capistrano-rails-collection'

#----------------------------------------------------------
################### RAILS CONFIGURATION ###################
#----------------------------------------------------------
inject_into_file 'config/application.rb', :before => "config.load_defaults 6.1" do

"\n # Ruta donde la libreria I18n debería buscar los archivos de traducción
I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]

# Traducciones disponibles permitidas por la aplicación
I18n.available_locales = [:en, :es]

# Confirguración regional predeterminada diferente a :en
I18n.default_locale = :es

# Quitar la generación de CSS de los scaffold
config.generators do |g|
  g.stylesheets false
end\n"
end

inject_into_file 'app/controllers/application_controller.rb', :after => "class ApplicationController < ActionController::Base" do
"
  def user_for_paper_trail
    logged_in? ? current_member.id : 'Public user'  # or whatever
  end

  include CanCan::ControllerAdditions
    before_action :authenticate_user!
    protect_from_forgery with: :exception

    rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
"
end

#----------------------------------------------------------
######################## TEMPLATES ########################
#----------------------------------------------------------

## Template Model
file 'lib/templates/active_record/model/model.rb.tt', <<-CODE 
<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
  has_paper_trail
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %><%= ', required: true' if attribute.required? %>
<% end -%>
<% attributes.select(&:token?).each do |attribute| -%>
  has_secure_token<% if attribute.name != "token" %> :<%= attribute.name %><% end %>
<% end -%>
<% if attributes.any?(&:password_digest?) -%>
  has_secure_password
<% end -%>  
end
<% end -%>
CODE

## Template Module (Helpers)
file 'lib/templates/active_record/model/module.rb.tt', <<-CODE 
module <%= class_path.map(&:camelize).join('::') %>
  def self.table_name_prefix
    '<%= namespaced? ? namespaced_class_path.join('_') : class_path.join('_') %>_'
  end
end
CODE

## Template Form
file 'lib/templates/erb/scaffold/_form.html.erb.tt', <<-CODE 
<%%= form_with(model: <%=singular_table_name%>, local: true) do |form| %>
  <%% if <%=singular_table_name%>.errors.any? %>
    <div id="error_explanation">
      <h2><%%= pluralize(<%=singular_table_name%>.errors.count, "error") %> prohibited this <%=singular_table_name.to_s%> from being saved:</h2>

      <ul>
      <%% <%=singular_table_name%>.errors.full_messages.each do |message| %>
        <li><%%= message %></li>
      <%% end %>  
      </ul>
    </div>
  <%% end %>
  <%- attributes.each do |attribute| -%>
    <div class="mb-3">
      <strong><%%= form.label :<%= attribute.name%>, <%=singular_table_name.camelize%>.human_attribute_name("<%= attribute.name %>").titleize, class:"form-label"%></strong>
      <%- if attribute.reference? -%>
      <%%= form.collection_select :<%= attribute.column_name %>, <%= attribute.name.camelize %>.all, :id, :name, {prompt: "Seleccionar"}, {class: "select2 form-control"}  %>
      <%- elsif attribute.field_type == :datetime_select -%>
      <%%= form.text_field :<%= attribute.name %>, class:"form-control flatpickr" %>
      <%- else -%>
      <%%= form.<%= attribute.field_type %> :<%= attribute.name %>, class:"form-control" %>
      <%- end -%>
    </div>
  <%- end -%>

  <div class="actions">
    <%%= link_to 'Volver', :back, class: "btn btn-primary" %>
    <%%= form.submit class: "btn btn-success" %>
<%% end %>
CODE

## Edit
file 'lib/templates/erb/scaffold/edit.html.erb.tt', <<-CODE 
<div class="mt-2">
  <ol class="breadcrumb mb-0">
    <li class="breadcrumb-item">
      <a href="/">Inicio</a>
    </li>
    <li class="breadcrumb-item">
      <a href="<%%= <%=plural_table_name%>_path%>"> <%%= <%= singular_table_name.camelize%>.model_name.human(count: 2)%></a>
    </li>
    <li class="breadcrumb-item active">Modificar  <%%= <%= singular_table_name.camelize%>.model_name.human%></li>
  </ol>
</div> 

<div class="card card-register mx-auto my-2">
  <div class="card-header">Modificar  <%%= <%= singular_table_name.camelize%>.model_name.human%></div>
  <div class="card-body">
    <%%= render 'form', <%=singular_table_name%>: @<%=singular_table_name%> %>
    <%%= link_to 'Eliminar ' + <%=singular_table_name.camelize%>.model_name.human.titleize, @<%=singular_table_name%>, method: :delete, data: { confirm: '¿Esta seguro que desea eliminar?' }, class: "btn btn-danger"%>
    </div>  
  </div>
</div>
CODE

## New
file 'lib/templates/erb/scaffold/new.html.erb.tt', <<-CODE 
<div class="mt-2">
  <ol class="breadcrumb mb-0">
    <li class="breadcrumb-item">
      <a href="/">Inicio</a>
    </li>
    <li class="breadcrumb-item">
      <a href="<%%= <%=plural_table_name%>_path%>"> <%%= <%= singular_table_name.camelize%>.model_name.human(count: 2)%></a>
    </li>
    <li class="breadcrumb-item active">Crear <%%= <%= singular_table_name.camelize%>.model_name.human%></li>
  </ol>
</div> 
<div class="card card-register mx-auto my-2">
  <div class="card-header">Crear <%%= <%= singular_table_name.camelize%>.model_name.human%></div>
  <div class="card-body">
    <%%= render 'form', <%=singular_table_name%>: @<%=singular_table_name%> %>
    </div>
  </div>
</div>
CODE

## Show
file 'lib/templates/erb/scaffold/show.html.erb.tt', <<-CODE 
<div class="mt-2">
  <ol class="breadcrumb mb-0">
    <li class="breadcrumb-item">
      <a href="/">Inicio</a>
    </li>
    <li class="breadcrumb-item">
      <a href="<%%= <%=plural_table_name%>_path%>"> <%%= <%= singular_table_name.camelize%>.model_name.human(count: 2)%></a>
    </li>
    <li class="breadcrumb-item active"><%%= <%= singular_table_name.camelize%>.model_name.human%></li>
  </ol>
</div> 
<div class="card card-register mx-auto my-2">
  <div class="card-header"><%%= @<%=singular_table_name%>.to_s %></div>
  <div class="card-body">
    <%- attributes.each do |attribute| -%>
      <p>
        <strong><%%= <%= singular_table_name.camelize%>.human_attribute_name("<%= attribute.name %>").titleize%>:</strong>
        <%%= @<%=singular_table_name%>.<%= attribute.name %> %>
      </p>
    <%- end -%>
    <div class="actions">
      <%%= link_to 'Volver', :back, class: "btn btn-primary" %>
      <%%= link_to 'Editar <%=singular_table_name.titleize%>', edit_<%=singular_table_name%>_path(@<%=singular_table_name%>), class: 'btn btn-primary' %>
      <%%= link_to 'Eliminar ' + <%=singular_table_name.camelize%>.model_name.human.titleize, @<%=singular_table_name%>, method: :delete, data: { confirm: '¿Esta seguro que desea eliminar?' }, class: "btn btn-danger"%>
    </div>
  </div>
</div>
CODE

## Index
file 'lib/templates/erb/scaffold/index.html.erb.tt', <<-CODE 
<!-- Breadcrumbs-->
<div class="mt-2">
  <ol class="breadcrumb mb-0">
    <li class="breadcrumb-item">
      <a href="/">Inicio</a>
    </li>
    <li class="breadcrumb-item active"><a href="<%%= <%=plural_table_name%>_path%>"> <%%= <%= singular_table_name.camelize%>.model_name.human(count: 2)%></a></li>
  </ol>
</div>
<div class="card mx-auto my-2">
  <div class="card-header">
    <i class="fa fa-table"></i>
    <%%= <%= singular_table_name.camelize%>.model_name.human(count: 2).titleize%>
  </div>
  <div class="card-body">
    <table class="datatable responsive nowrap table table-hover">
      <thead>
        <tr>
          <%- attributes.each do |attribute| -%>
          <th><%%= <%= singular_table_name.camelize%>.human_attribute_name("<%= attribute.name %>").titleize%></th>
          <%- end -%>
          <th>Opciones</th>
        </tr>

      </thead>

      <tbody>
        <%% @<%=plural_table_name%>.each do |<%=singular_table_name%>| %>
          <tr>
            <%- attributes.each do |attribute| -%>
              <td><%%=<%=singular_table_name%>.<%= attribute.name %>%></td>
            <%- end -%>
            <td>
              <%%= link_to((fa_icon "eye"), <%=singular_table_name%>) %>
              <%%= link_to((fa_icon "edit"), edit_<%=singular_table_name%>_path(<%=singular_table_name%>)) %>
              <%%= link_to((fa_icon "trash"), <%=singular_table_name%>, method: :delete, data: { confirm: '¿Esta seguro que desea eliminar?' }) %>
            </td>
          </tr>
        <%% end %>
      </tbody>
    </table>
  </div>
  <div class="card-footer small text-muted">Updated yesterday at 11:59 PM</div>
</div>

<div class="actions">
  <%%= link_to 'Volver', :back, class: "btn btn-primary" %>
  <%%= link_to 'Crear ' + <%=singular_table_name.camelize%>.model_name.human.titleize, new_<%=singular_table_name%>_path, class: 'btn btn-success' %>
</div>
<!-- End Scaffold -->
CODE

#----------------------------------------------------------
###################### VISTAS LAYOUTS #####################
#----------------------------------------------------------

## SIGNIN
file 'app/views/layouts/_signin.html.erb', <<-CODE 
<%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
  <div class="text-center">
    <%= fa_icon "user-md", style: "font-size: 200px; color: #2C5485;"%>
  </div>
  <div class="form-group">
    <%= f.label :email%>
    <%= f.email_field :email, :class => "form-control", autofocus: true, autocomplete: "email"   %>
  </div>
  <div class="form-group mb-2">
    <%= f.label :password%>
    <%= f.password_field :password, :class => "form-control", autocomplete: "current-password"   %>
  </div>
  <% if devise_mapping.rememberable? %>
    <div class="form-group mb-2">
      <%= f.check_box :remember_me %>
      <%= f.label :remember_me, "Recordarme" %>
    </div>
  <% end %>
  <div class="d-grid gap-2">
    <%= f.submit "Ingresar", :class => "btn btn-primary btn-block" %>
  </div>
<% end %>
CODE

## EDIT
file 'app/views/layouts/_edit.html.erb', <<-CODE 
<%= form_for(resource, as: resource_name, url: registration_path(resource_name), html: { method: :put }) do |f| %>
  <div class="text-center">
    <%= fa_icon "user-md", style: "font-size: 200px; color: #2C5485;"%>
  </div>

  <div class="form-group mb-3">
    <strong><%= f.label :email %></strong>
    <%= f.email_field :email, autofocus: true, autocomplete: "email", :class => "form-control" %>
  </div>

  <% if devise_mapping.confirmable? && resource.pending_reconfirmation? %>
    <div>Currently waiting confirmation for: <%= resource.unconfirmed_email %></div>
  <% end %>

  <div class="form-group mb-3">
    <strong><%= f.label :password %> </strong><i>(Dejar en blanco si no quiere modificarla)</i><br/>
    <%= f.password_field :password, autocomplete: "new-password", :class => "form-control" %>
    <% if @minimum_password_length %>
      <em><%= @minimum_password_length %> characters minimum</em>
    <% end %>
  </div>

  <div class="form-group mb-3">
    <strong><%= f.label :password_confirmation %></strong><br />
    <%= f.password_field :password_confirmation, autocomplete: "new-password", :class => "form-control" %>
  </div>

  <div class="form-group mb-3">
    <strong><%= f.label :current_password %> </strong><i>(Necesitas tu clave actual para actualizar)</i><br/>
    <%= f.password_field :current_password, autocomplete: "current-password", :class => "form-control" %>
  </div>

  <div class="d-grid gap-2">
    <%= f.submit "Actualizar", :class => "btn btn-primary btn-block" %>
  </div>
<% end %>
CODE

## FLASH
file 'app/views/layouts/_flash.html.erb', <<-CODE 
<% unless flash.empty? %>
  <script type="text/javascript">
    <% flash.each do |f| %>
      <% type = f[0].to_s.gsub('alert', 'error').gsub('notice', 'info') %>
      toastr['<%= type %>']('<%= f[1] %>');
    <% end %>
  </script>
<% end %>
CODE


## NAVBAR
file 'app/views/layouts/_navbar.html.erb', <<-CODE 
<nav class="navbar navbar-expand-md fixed-top navbar-dark bg-primary">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="/">MINISTERIO DE SALUD</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <% if user_signed_in? %>
    <div class="collapse navbar-collapse" id="navbarCollapse">
      <ul class="navbar-nav me-auto mb-2 mb-md-0">
        <li class="nav-item">
          <a class="nav-link" aria-current="page" href="#">Home</a>
        </li>
        <% if current_user.admin? %>
        <li class="nav-item">
          <a class="nav-link" href="/admin">Admin</a>
        </li>
        <% end %>
      </ul>
      <form class="d-flex">
        <ul class="navbar-nav me-auto mb-2 mb-md-0">
          <li class="nav-item">
            <%= link_to current_user.email, edit_user_registration_path, :class => "nav-link" %>
          </li>
          <li class="nav-item">
            <%= link_to "Salir", destroy_user_session_path, :method => :delete, :class => "nav-link" %>  
          </li>

        </ul>
      </form>
    </div>
    <% end %>
  </div>
</nav>

CODE

## FOOTER
file 'app/views/layouts/_footer.html.erb', <<-CODE 
<footer class="footer mt-auto bg-primary text-white text-center text-lg-start">
  <!-- Copyright -->
  <div class="text-left">
    2021 © Ministerio de Salud - Dirección Provincial de Informática
  </div>
  <!-- Copyright -->
</footer>
CODE

## APPLICATION
remove_file 'app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-CODE 
<!DOCTYPE html>
<html>
  <head>
    <title>Sistema Template</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
    <link type="text/css" rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Encode+Sans:wght@100;200;300;400;500;600;700;800;900&amp;display=swap" media="all">
    <%= favicon_link_tag asset_path('http://www.chubut.gov.ar/favicon.ico') %>
  </head>

  <body id="page-top" class="<%= controller_name %> <%= action_name %> bg-light d-flex flex-column h-100">
    <%= render "layouts/flash"%>
    <header>
      <%= render "layouts/navbar"%>
    </header>
    <main class="flex-shrink-0">
      <div class="container">
        <%= yield %>
      </div>
    </main>
    <%= render "layouts/footer"%>
  </body>
</html>
CODE

#----------------------------------------------------------
###################### VISTAS DEVISE ######################
#----------------------------------------------------------

## NEW
file 'app/views/devise/sessions/new.html.erb', <<-CODE 
<section id="login" class="login-section py-5">
  <div class="row my-2 justify-content-center">
    <div class="col-md-4 col-sm-12 col-xs-12">
      <div class="d-grid gap-2">
        <%= render "layouts/signin"%>
      </div>
    </div>
  </div>
</section>
CODE

## EDIT
file 'app/views/devise/registrations/edit.html.erb', <<-CODE 
<section id="devise-edit" class="login-section py-5">
  <div class="row my-2 justify-content-center">
    <div class="col-md-4 col-sm-12 col-xs-12">
      <div class="d-grid gap-2">
        <%= render "layouts/edit"%>
      </div>
    </div>
  </div>
</section>
CODE

#----------------------------------------------------------
####################### WELCOME ###########################
#----------------------------------------------------------

file 'app/controllers/welcome_controller.rb', <<-CODE 
class WelcomeController < ApplicationController
	skip_before_action :authenticate_user!, only: [:index]
end
CODE


file 'app/views/welcome/index.html.erb', <<-CODE 
<div class="m-3">
	<h1 class="cover-heading text-center ">SISTEMA BASE.</h1>
	<p>Bienvenido/a <% if user_signed_in? %><a href="#"><%=current_user.email%></a><% end %> al Sistema que sirve como base para el desarrollo de aplicaciones en la Dirección Provincial de Informática del Ministerio de Salud de la Provincia de Chubut, el mismo se diseño bajo el lenguaje de programación Ruby 3.0.1 y el framework para aplicaciones web Ruby on Rails 6.1.3.2 Usa como framework de diseño Bootstrap 5.</p>
	<% if !user_signed_in? %>
	  <p class="lead text-center ">
	    <a href="users/sign_in" class="btn btn-block btn-lg btn-primary">Ingresar</a>
	  </p>
	<% end %>
</div>
CODE

# Setear la ruta de inicio
route "root to: 'welcome#index'"



#----------------------------------------------------------
######################## ASSETS ###########################
#----------------------------------------------------------

## APPLICATION JS - IMPORTS 
inject_into_file 'app/javascript/packs/application.js', :after => 'import "channels"' do
"\n
// FONTAWESOME
import '@fortawesome/fontawesome-free/css/all'
global.toastr = require('toastr')

// DATATABLE
require('datatables.net-bs5')

// SELECT2
import select2 from 'select2';
import 'select2/dist/css/select2.css';
import 'select2-bootstrap-theme/dist/select2-bootstrap'

$(document).ready(function() {
  $('select').select2();
});

//BOOTSTRAP
import 'packs/bootstrap.bundle.min'

// FULLCALLENDAR
import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import momentPlugin from '@fullcalendar/moment';
import esLocale from '@fullcalendar/core/locales/es';

window.Calendar = Calendar;
window.dayGridPlugin = dayGridPlugin;
window.timeGridPlugin = timeGridPlugin;
window.listPlugin = listPlugin;
window.momentPlugin = momentPlugin;
window.esLocale = esLocale;

//FLATPICKR
require('flatpickr')
import flatpickr from 'flatpickr';
import { Spanish } from 'flatpickr/dist/l10n/es.js'

import 'css/application'"
end

## CREATE APPLICATION CSS FOR WEBPACKER
run "mkdir app/javascript/css"

# Application
file 'app/javascript/css/application.scss', <<-CODE 
@import 'flatpickr/dist/flatpickr.css';
@import '@fullcalendar/common/main.css';
@import '@fullcalendar/daygrid/main.css';
@import '@fullcalendar/timegrid/main.css';
@import '@fullcalendar/list/main.css';
@import 'toastr';

CODE

## APPLICATION JS - CONFIGURATION 
inject_into_file 'app/javascript/packs/application.js', :after => "ActiveStorage.start()" do
"\n
$.fn.extend({
  integrateSelect2: function(selector) {
    selector = selector || '.select2';
    return $(this).find(selector).select2({
      theme: 'bootstrap',
      width: '100%',
      allowClear: false
    });
  },
  integrateFlatpickr: function(selector) {
    selector = selector || '.flatpickr';
    return $(this).find(selector).flatpickr({
      enableTime: true,
      dateFormat: 'Y-m-d H:i',
      altInput: true,
      altFormat: 'j F, Y - H:i',
      'locale': Spanish
    });
  }
});

$(document).on('turbolinks:load', function() {
  var datatable, form;
  datatable = $('.datatable');
  datatable.DataTable({
    'dom': 'Bfrtip',
    'language': {
      'url': '//cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/Spanish.json'
    },
    'bPaginate': true,
    'info': false,
    'responsive': true,
    'deferRender': true,
    'stateSave': true,
    'bDestroy': true,
  });

  form = $('form');
  form.integrateSelect2();
  form.integrateFlatpickr();

});

$(document).on('turbolinks:before-cache', function() {
  var dataTable;
  dataTable = $($.fn.dataTable.tables(true)).DataTable();
  if (dataTable !== null) {
    return dataTable.destroy();
  }
});

toastr.options = {
  'closeButton': false,
  'debug': false,
  'newestOnTop': false,
  'progressBar': false,
  'positionClass': 'toast-top-right',
  'preventDuplicates': true,
  'preventOpenDuplicates': true,
  'onclick': null,
  'showDuration': '0',
  'hideDuration': '0',
  'timeOut': '0',
  'extendedTimeOut': '0',
  'tapToDismiss': true,
  'showEasing': 'swing',
  'hideEasing': 'linear',
  'showMethod': 'fadeIn',
  'hideMethod': 'fadeOut'
}"
end

## STYLES SCSS
file 'app/assets/stylesheets/style.scss', <<-CODE 
@charset "UTF-8";

//BOOTSTRAP THEME CSS
:root {
  --bs-blue: #4e719c;
  --bs-indigo: #6610f2;
  --bs-purple: #6f42c1;
  --bs-pink: #d63384;
  --bs-red: #dc3545;
  --bs-orange: #fd7e14;
  --bs-yellow: #ffc107;
  --bs-green: #198754;
  --bs-teal: #20c997;
  --bs-cyan: #0dcaf0;
  --bs-white: #fff;
  --bs-gray: #6c757d;
  --bs-gray-dark: #343a40;
  --bs-gray-100: #f8f9fa;
  --bs-gray-200: #e9ecef;
  --bs-gray-300: #dee2e6;
  --bs-gray-400: #ced4da;
  --bs-gray-500: #adb5bd;
  --bs-gray-600: #6c757d;
  --bs-gray-700: #495057;
  --bs-gray-800: #343a40;
  --bs-gray-900: #212529;
  --bs-primary: #4e719c;
  --bs-secondary: #6c757d;
  --bs-success: #198754;
  --bs-info: #0dcaf0;
  --bs-warning: #ffc107;
  --bs-danger: #dc3545;
  --bs-light: #f8f9fa;
  --bs-dark: #212529;
  --bs-primary-rgb: 44, 84, 133;
  --bs-secondary-rgb: 108,117,125;
  --bs-success-rgb: 25,135,84;
  --bs-info-rgb: 13,202,240;
  --bs-warning-rgb: 255,193,7;
  --bs-danger-rgb: 220,53,69;
  --bs-light-rgb: 248,249,250;
  --bs-dark-rgb: 33,37,41;
  --bs-white-rgb: 255,255,255;
  --bs-black-rgb: 0,0,0;
  --bs-body-color-rgb: 33,37,41;
  --bs-body-bg-rgb: 255,255,255;
  --bs-font-sans-serif: system-ui,-apple-system,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Noto Sans","Liberation Sans",sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji";
  --bs-font-monospace: SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono","Courier New",monospace;
  --bs-gradient: linear-gradient(180deg, rgba(255, 255, 255, 0.15), rgba(255, 255, 255, 0));
  --bs-body-font-family: var(--bs-font-sans-serif);
  --bs-body-font-size: 1rem;
  --bs-body-font-weight: 400;
  --bs-body-line-height: 1.5;
  --bs-body-color: #212529;
  --bs-body-bg: #fff;
}

a {color: var(--bs-blue);}
.btn-primary {
  background-color:rgba(var(--bs-primary-rgb),var(--bs-bg-opacity));
  border-color:rgba(var(--bs-primary-rgb),var(--bs-bg-opacity));
}
.page-link {color: var(--bs-blue);}
.page-item.active .page-link {
  background-color: var(--bs-blue);
  border-color: var(--bs-blue);
}

//PERSONAL THEME CSS

html {height:100%;}

body {
  font-family: -apple-system, system-ui, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  font-size: 0.9rem;
  font-weight: normal;
  line-height: 1.5;
  color: #000;
  padding: 60px 0 0 0;
}

.footer {
  width: 100%;
  line-height: 60px;
  padding: 0 1rem;
  min-height: 60px;
}

.select2-container .select2-selection--single {
  height: calc(1.5em + 0.75rem + 2px);
  line-height: 1.428571429;
  padding: 6px 24px 6px 12px;
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.5;
  color: #495057;
  background-color: #fff;
  background-clip: padding-box;
  border: 1px solid #ced4da;
  border-radius: 0.25rem;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.select2-container .select2-selection--single {
  height: 39px !important;
}

.select2-container .select2-selection--single .select2-selection__rendered {
  padding-left: 0px !important;
}

.select2-container--default .select2-selection--single .select2-selection__arrow {
  top: 7px !important;
}

.select2-container--default .select2-results__option--highlighted.select2-results__option--selectable {
  background-color: var(--bs-blue) !important;

}

.flatpickr[readonly] {
  background-color: white;
  opacity: 1; 
  cursor: pointer;  
}

.actions {margin: 1rem 0;}
.fc-event{cursor: pointer;}

.breadcrumb
{
  padding: .5rem 1rem;
  margin-bottom: 0;
  background-color: rgba(0,0,0,.03);
  border: 1px solid rgba(0,0,0,.125);
  border-radius: 4px;
}


CODE

#----------------------------------------------------------
############## WGET FILES & CSS COMPILATEDS ###############
#----------------------------------------------------------
# TAKE FAVICON CHUBUT
run "wget http://www.chubut.gov.ar/favicon.ico -P app/assets/images"

# TAKE BOOTSTRAP 5.1 COMPILED
run "wget https://cdn.jsdelivr.net/npm/bootstrap@5.1.1/dist/js/bootstrap.bundle.min.js -P app/javascript/packs"
run "wget https://cdn.jsdelivr.net/npm/bootstrap@5.1.1/dist/css/bootstrap.min.css -P app/assets/stylesheets"

# IDIOMA
## ES
run "wget https://raw.githubusercontent.com/chubutdpi/config_files/master/es.yml -P config/locales"

## DEVISE ES
run "wget https://raw.githubusercontent.com/chubutdpi/config_files/master/devise.es.yml -P config/locales"

## RAILS ADMIN ES
run "wget https://raw.githubusercontent.com/chubutdpi/config_files/master/rails_admin.es.yml -P config/locales"

# SEED
remove_file 'db/seeds.rb'
run "wget https://raw.githubusercontent.com/chubutdpi/config_files/master/seeds.rb -P db"

#----------------------------------------------------------
#----------------------------------------------------------
###################### AFTER BUNDLE #######################
#----------------------------------------------------------
#----------------------------------------------------------

after_bundle do

	# REINICIAR BD DEVELOPMENT
	rails_command "db:environment:set RAILS_ENV=development"
	rails_command "db:drop"
	rails_command "db:create"

	# CONFIGURAR CAPISTRANO
	## CAPFILE
	file 'Capfile', <<-CODE 
# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rails'
require 'capistrano/passenger'
require 'capistrano/rbenv'

require 'capistrano/rails/collection'

set :rbenv_type, :user
set :rbenv_ruby, '3.0.2'

# Load the SCM plugin appropriate to your project:
#
# require 'capistrano/scm/hg'
# install_plugin Capistrano::SCM::Hg
# or
# require 'capistrano/scm/svn'
# install_plugin Capistrano::SCM::Svn
# or
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
# require 'capistrano/bundler'
# require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'
# require 'capistrano/passenger'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
	CODE

	## CONFIG / DEPLOY
	file 'config/deploy.rb', <<-CODE 
# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "#{ARGV[1]}"

set :repo_url, "git@github.com:chubutdpi/#{ARGV[1]}.git"

# Deploy to the user's home directory
set :deploy_to, "/home/deploy/#{ARGV[1]}"

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads', 'public/packs', 'node_modules'

# Only keep the last 5 releases to save disk space
set :keep_releases, 5

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
	CODE

	## CONFIG / DEPLOY / PRODUCTION
	file 'config/deploy/production.rb', <<-CODE 
# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

server '45.235.225.59', user: 'deploy', roles: %w{app db web}

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}

# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/user_name/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
	CODE

	# RUN YARN 
	run "yarn add jquery@3.6.0"
	run "yarn add moment"
	run "yarn add toastr"
	run "yarn add @fortawesome/fontawesome-free"
	run "yarn add datatables.net-bs5"
	run "yarn add datatables.net-responsive-bs5"
	run "yarn add select2"
	run "yarn add bootstrap-datepicker"
	run "yarn add flatpickr"
	run "yarn add @fullcalendar/core @fullcalendar/moment @fullcalendar/bootstrap @fullcalendar/daygrid @fullcalendar/timegrid @fullcalendar/list"

	# CONFIG DEVISE CANCAN & ROLIFY
	generate("devise:install")
	generate("devise User")
	generate("cancan:ability")
	generate("rolify Role User")   

	## CONFIG CANCAN ABILITY
	remove_file 'app/models/ability.rb'
	file 'app/models/ability.rb', <<-CODE 
class Ability
include CanCan::Ability

def initialize(user)
  user ||= User.new # guest user (not logged in)
  if user.admin?
    can :manage, :all
  else
    can :read, :all
  end
end
end
	CODE

	# INSERT FUNCTION ADMIN? IN uSER CLASS
	inject_into_file 'app/models/user.rb', :before => "end" do
	"
	def admin?
		return has_role? :admin
	end\n"
	end

	# INSTALL RAILS ADMIN & PAPER TRAIL
	generate("rails_admin:install")
	generate("paper_trail:install [--with-changes]")

	# CONFIG RAILS ADMIN
	remove_file 'config/initializers/rails_admin.rb'
	file 'config/initializers/rails_admin.rb', <<-CODE 
RailsAdmin.config do |config|

### Popular gems integration
## == Devise ==
config.authenticate_with do
  warden.authenticate! scope: :user
end
config.current_user_method(&:current_user)

## == CancanCan ==
config.authorize_with :cancancan

## == Pundit ==
#config.authorize_with :pundit

## == PaperTrail ==
config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

## == Gravatar integration ==
## To disable Gravatar integration in Navigation Bar set to false
#config.show_gravatar = true

config.actions do
  dashboard                     # mandatory
  index                         # mandatory
  new
  export
  bulk_delete
  show
  edit
  delete
  show_in_app
  history_index
  history_show
end

# NOMBRE DE LA APP
config.main_app_name = ["MINISTERIO DE SALUD", "Administración"]

# LINKS A OTRAS WEBS
config.navigation_static_label = "Otras Webs"
config.navigation_static_links = {'Google' => 'http://www.google.com'}
end
	CODE

	# CONFIG JQUERY WITH GLOBAL VAR
	inject_into_file 'config/webpack/environment.js', :after => "const { environment } = require('@rails/webpacker')" do
	"\n
	const webpack = require('webpack')

	environment.plugins.append('Provide', new webpack.ProvidePlugin({
		$: 'jquery',
		jQuery: 'jquery',
		Popper: 'popper.js/dist/popper'
	}))"
	end
  
  ## CREATE INITIAL SCAFFOLDS
  generate("scaffold Country code:string name:string")
  generate("scaffold Nationality code:string name:string country:references")  
  generate("scaffold Province iso_id:string name:string national_id:integer  country:references complete_name:string iso_name:string lat:decimal{8,2} lon:decimal{8,2}")
  generate("scaffold Department complete_name:string name:string national_id:integer province:references category:string lat:decimal{8,2} lon:decimal{8,2}")
  generate("scaffold Locality name:string national_id:integer department:references category:string lat:decimal{8,2} lon:decimal{8,2}")
  generate("scaffold events title:string start:datetime end:datetime url:string classNames:string backgroundColor:string borderColor:string textColor:string")

  # EDIT EVENT.
  inject_into_file 'app/views/events/index.html.erb', :after => "<!-- End Scaffold -->" do
  "\n
  <div class='card mx-auto my-2'>
    <div class='card-header'>
      <i class='fa fa-table'></i>
      Calendario
    </div>
    <div class='card-body'>
      <div id='calendar'></div>
    </div>
  </div>
  <script>
  document.addEventListener('turbolinks:load', function() {
    var calendarEl = document.getElementById('calendar');
    var calendar = new Calendar(calendarEl, {
      plugins: [ momentPlugin, timeGridPlugin, dayGridPlugin, listPlugin ],
      locale: esLocale,
      themeSystem: 'bootstrap',
      hiddenDays: [ 0, 6] ,
      timeZone:'UTC',
      headerToolbar:{
        left:'prev,next,today',
        center:'title',
        right:'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
      },
      events: [
        <% @events.each do |event| %>
        {
          allDay:false,
          title: '<%=event.title%>',
          url : '/events/<%=event.id%>',
          <% if event.end.nil? %>
          start: '<%=event.start.strftime('%Y-%m-%dT%H:%M:%S')%>'
          <% else %>  
          start: '<%=event.start.strftime('%Y-%m-%dT%H:%M:%S')%>', // a property!
          end: '<%=event.end.strftime('%Y-%m-%dT%H:%M:%S')%>'
          <% end %>
        <% if event == @events.last %>
        }
        <% else %>
        },
        <% end %>
        <% end %>
        
      ],
      eventClick: function(info) {
        //alert('Event: ' + info.event.id);
        //alert('Coordinates: ' + info.jsEvent.pageX + ',' + info.jsEvent.pageY);
        //alert('View: ' + info.view.type);

        // change the border color just for fun
        //info.el.style.borderColor = 'red';
      }
    });

    calendar.render();



  });
  </script>"
  end

  # Correr las Migraciones
  rails_command "db:migrate"

  # Poblar la Base de Datos con información Inicial
  rails_command "db:seed"

	
	

	#----------------------------------------------------------
	####################### WELCOME ###########################
	#----------------------------------------------------------

	run "sed -i 's/username: lawen/username: deploy/g' config/database.yml"

	run "git init"
	run "git add ."
	run "git commit -m 'first commit'"
	run "git branch -M master"
	run "git remote add origin git@github.com:chubutdpi/lawen.git"
  run "git push --set-upstream origin master"


	#------------------------------------------------------------------------------
	# * Eliminar la Base de Datos si ya existe en el servidor
	#			postgres=# drop database lawen;
	# * Crear Base de Datos en el servidor
	# 		postgres=# create database lawen;		
	# * Agregar Public Key en GitHub en el servidor
	# * Configurar RAILS_MASTER_KEY y SECRET_KEY_BASE en el servidor
	#     EDITOR=nano rails credentials:edit
	#------------------------------------------------------------------------------
end