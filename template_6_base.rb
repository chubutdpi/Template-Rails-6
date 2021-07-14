#----------------------------------------------------------
######################### GEMFILE #########################
#----------------------------------------------------------

# Manejo de Usuarios y Roles
# https://github.com/RolifyCommunity/rolify/wiki/Devise---CanCanCan---rolify-Tutorial
gem 'devise'
gem 'cancancan'
gem 'rolify'

gem 'font-awesome-rails'

gem 'rails_admin', '~> 2.0'

gem 'paper_trail'

#----------------------------------------------------------
################## CREACIÓN DE TEMPLATES ##################
#----------------------------------------------------------
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



file 'lib/templates/active_record/model/module.rb.tt', <<-CODE 
module <%= class_path.map(&:camelize).join('::') %>
  def self.table_name_prefix
    '<%= namespaced? ? namespaced_class_path.join('_') : class_path.join('_') %>_'
  end
end
CODE


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
      <%- elsif attribute.field_type == :date_select -%>
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


file 'lib/templates/erb/scaffold/edit.html.erb.tt', <<-CODE 
<div class="p-2">
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

file 'lib/templates/erb/scaffold/new.html.erb.tt', <<-CODE 
<div class="p-2">
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

file 'lib/templates/erb/scaffold/show.html.erb.tt', <<-CODE 
<div class="p-2">
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

file 'lib/templates/erb/scaffold/index.html.erb.tt', <<-CODE 
<!-- Breadcrumbs-->
<div class="p-2">
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
CODE

#----------------------------------------------------------
######################## LAYOUTS ##########################
#----------------------------------------------------------

#----------------------- SIGNIN ---------------------------
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

#------------------------ EDIT ----------------------------
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

#----------------------- FLASH ----------------------------
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


#------------------------ NAVBAR --------------------------
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

#-------------------------- FOOTER ------------------------
file 'app/views/layouts/_footer.html.erb', <<-CODE 
<footer class="footer mt-auto bg-primary text-white text-center text-lg-start">
  <!-- Copyright -->
  <div class="text-left">
    2021 © Ministerio de Salud - Dirección Provincial de Informática
  </div>
  <!-- Copyright -->
</footer>
CODE

#----------------------- APPLICATION ----------------------
remove_file 'app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-CODE 
<!DOCTYPE html>
<html>
  <head>
    <title>Sistema Template</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

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
####################### WELCOME ###########################
#----------------------------------------------------------

file 'app/controllers/welcome_controller.rb', <<-CODE 
class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
end
CODE

#----------------------------------------------------------
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
  end"
end


#----------------------------------------------------------
######################## SEED #############################
#----------------------------------------------------------
remove_file 'db/seeds.rb'
file 'db/seeds.rb', <<-CODE

user = User.new
user.email = 'admin@chubut.gov.ar'
user.password = 'admin123'
user.save!
user.add_role 'admin'

countries_list = [
  ['Argentina', 'ar'],
  ['Brasil', 'br'],
  ['Chile', 'cl']
]

countries_list.each do |name, code|
  Country.find_or_create_by(name: name, code:code)
end


nationalities_list = [
  ['Argentino/a', 'ar', 1],
  ['Brasileño/a', 'br', 2],
  ['Chileno/a', 'cl', 3]
]

nationalities_list.each do |name, code, country_id|
  Nationality.find_or_create_by(name: name, code:code, country: Country.where(id:country_id).first)
end

provinces_list = [
  ["Provincia de Misiones","AR-N","Misiones",54,"Misiones",-26.8753965086829,-54.6516966230371,1],
  ["Provincia de San Luis","AR-D","San Luis",74,"San Luis",-33.7577257449137,-66.0281298195836,1],
  ["Provincia de San Juan","AR-J","San Juan",70,"San Juan",-30.8653679979618,-68.8894908486844,1],
  ["Provincia de Entre Ríos","AR-E","Entre Ríos",30,"Entre Ríos",-32.0588735436448,-59.2014475514635,1],
  ["Provincia de Santa Cruz","AR-Z","Santa Cruz",78,"Santa Cruz",-48.8154851827063,-69.9557621671973,1],
  ["Provincia de Río Negro","AR-R","Río Negro",62,"Río Negro",-40.4057957178801,-67.229329893694,1],
  ["Provincia del Chubut","AR-U","Chubut",26,"Chubut",-43.7886233529878,-68.5267593943345,1],
  ["Provincia de Córdoba","AR-X","Córdoba",14,"Córdoba",-32.142932663607,-63.8017532741662,1],
  ["Provincia de Mendoza","AR-M","Mendoza",50,"Mendoza",-34.6298873058957,-68.5831228183798,1],
  ["Provincia de La Rioja","AR-F","La Rioja",46,"La Rioja",-29.685776298315,-67.1817359694432,1],
  ["Provincia de Catamarca","AR-K","Catamarca",10,"Catamarca",-27.3358332810217,-66.9476824299928,1],
  ["Provincia de La Pampa","AR-L","La Pampa",42,"La Pampa",-37.1315537735949,-65.4466546606951,1],
  ["Provincia de Santiago del Estero","AR-G","Santiago del Estero",86,"Santiago del Estero",-27.7824116550944,-63.2523866568588,1],
  ["Provincia de Corrientes","AR-W","Corrientes",18,"Corrientes",-28.7743047046407,-57.8012191977913,1],
  ["Provincia de Santa Fe","AR-S","Santa Fe",82,"Santa Fe",-30.7069271588117,-60.9498369430241,1],
  ["Provincia de Tucumán","AR-T","Tucumán",90,"Tucumán",-26.9478001830786,-65.3647579441481,1],
  ["Provincia del Neuquén","AR-Q","Neuquén",58,"Neuquén",-38.6417575824599,-70.1185705180601,1],
  ["Provincia de Salta","AR-A","Salta",66,"Salta",-24.2991344492002,-64.8144629600627,1],
  ["Provincia del Chaco","AR-H","Chaco",22,"Chaco",-26.3864309061226,-60.7658307438603,1],
  ["Provincia de Formosa","AR-P","Formosa",34,"Formosa",-24.894972594871,-59.9324405800872,1],
  ["Provincia de Jujuy","AR-Y","Jujuy",38,"Jujuy",-23.3200784211351,-65.7642522180337,1],
  ["Ciudad Autónoma de Buenos Aires","AR-C","Ciudad Autónoma de Buenos Aires",02,"Ciudad Autónoma de Buenos Aires",-34.6144934119689,-58.4458563545429,1],
  ["Provincia de Buenos Aires","AR-B","Buenos Aires",06,"Buenos Aires",-36.6769415180527,-60.5588319815719,1],
  ["Provincia de Tierra del Fuego, Antártida e Islas del Atlántico Sur","AR-V","Tierra del Fuego, Antártida e Islas del Atlántico Sur",94,"Tierra del Fuego",-82.52151781221,-50.7427486049785,1]
]

provinces_list.each do |complete_name, iso_id, name, national_id, iso_name, lat, lon, country|
  Province.find_or_create_by(complete_name: complete_name, iso_id: iso_id, name: name, national_id: national_id, iso_name: iso_name, lat: lat, lon: lon, country_id:country)
end

departments_list =[
  ["Partido de José C. Paz","José C. Paz","06412","06","Partido",-34.5118758903445,-58.7776710941743],
  ["Departamento O'Higgins","O'Higgins","22112","22","Departamento",-27.2575511794731,-60.6806781684245],
  ["Departamento Trenel","Trenel","42147","42","Departamento",-35.6318750123361,-64.2143766258097],
  ["Partido de Adolfo Gonzales Chaves","Adolfo Gonzales Chaves","06014","06","Partido",-37.9642254145303,-60.2490776485677],
  ["Partido de General Juan Madariaga","General Juan Madariaga","06315","06","Partido",-37.1532136536641,-57.2307866316173],
  ["Partido de Tandil","Tandil","06791","06","Partido",-37.3356554181577,-59.181805577778],
  ["Departamento Alberdi","Alberdi","86014","86","Departamento",-26.5210512908819,-62.7274743405239],
  ["Departamento Quemú Quemú","Quemú Quemú","42119","42","Departamento",-36.1306397823227,-63.663736169201],
  ["Departamento Capital","Capital","42021","42","Departamento",-36.4980625981793,-64.198128304727],
  ["Departamento Rivadavia","Rivadavia","86154","86","Departamento",-30.0205633751884,-62.2804530355771],
  ["Departamento Juan F. Ibarra","Juan F. Ibarra","86098","86","Departamento",-28.0394963430537,-62.5440138783592],
  ["Departamento General Taboada","General Taboada","86077","86","Departamento",-28.5682847400822,-62.3388258455986],
  ["Departamento La Paz","La Paz","50042","50","Departamento",-33.7114684971791,-67.2475409227538],
  ["Partido de Coronel Pringles","Coronel Pringles","06196","06","Partido",-38.1477437843902,-61.2646589620305],
  ["Partido de Tigre","Tigre","06805","06","Partido",-34.3815893993371,-58.599453988125],
  ["Departamento Catriló","Catriló","42028","42","Departamento",-36.5816678881383,-63.6648708546651],
  ["Departamento Atreucó","Atreucó","42007","42","Departamento",-37.0324956718132,-63.7788855690903],
  ["Departamento Guatraché","Guatraché","42070","42","Departamento",-37.4836474005921,-63.7813086707571],
  ["Departamento Utracán","Utracán","42154","42","Departamento",-37.3338794806846,-65.0828316677234],
  ["Departamento Loventué","Loventué","42098","42","Departamento",-36.4787683011276,-65.5329694083622],
  ["Departamento Hucal","Hucal","42077","42","Departamento",-37.9792340442423,-63.9544827643711],
  ["Departamento Chalileo","Chalileo","42049","42","Departamento",-36.3954095124282,-66.5727556640635],
  ["Departamento Chical Co","Chical Co","42063","42","Departamento",-36.3978994715573,-67.6953932639542],
  ["Departamento Esquina","Esquina","18049","18","Departamento",-29.9854770547953,-59.2414216570581],
  ["Departamento Sauce","Sauce","18175","18","Departamento",-29.9995445616697,-58.7950373826119],
  ["Departamento Curuzu Cuatia","Curuzu Cuatia","18035","18","Departamento",-29.6955178131115,-58.3248439252656],
  ["Departamento San Martín","San Martín","18147","18","Departamento",-28.8289705275493,-56.9315923506787],
  ["Departamento Rawson","Rawson","26077","26","Departamento",-43.1372229709113,-65.0757246833498],
  ["Departamento Mercedes","Mercedes","18105","18","Departamento",-29.0645100901984,-57.818389954722],
  ["Departamento Paso de los Libres","Paso de los Libres","18119","18","Departamento",-29.5936355856024,-57.2996337303242],
  ["Departamento General Alvear","General Alvear","18056","18","Departamento",-28.7751848033313,-56.5115297991712],
  ["Departamento Choya","Choya","86063","86","Departamento",-28.7536335933641,-64.7638996164731],
  ["Departamento Santa Rosa","Santa Rosa","50112","50","Departamento",-33.6177946030973,-67.9636620466005],
  ["Departamento Rivadavia","Rivadavia","50084","50","Departamento",-33.419707109754,-68.6121759957283],
  ["Partido de Tornquist","Tornquist","06819","06","Partido",-38.255785801668,-62.2904249803924],
  ["Departamento Chamical","Chamical","46035","46","Departamento",-30.1677065304375,-65.9562869452052],
  ["Departamento Arauco","Arauco","46007","46","Departamento",-28.5330735278082,-66.7191515033817],
  ["Partido de Campana","Campana","06126","06","Partido",-34.1381957287934,-58.8830222693056],
  ["Departamento Santa Rosa","Santa Rosa","10098","10","Departamento",-28.0814710804867,-65.3349462642257],
  ["Departamento La Paz","La Paz","10070","10","Departamento",-29.3952000610314,-65.1919504325436],
  ["Departamento Magallanes","Magallanes","78042","78","Departamento",-48.8383418225325,-68.4681621286703],
  ["Departamento Corpen Aike","Corpen Aike","78007","78","Departamento",-49.9474837007267,-69.4469507225498],
  ["Departamento Conesa","Conesa","62028","62","Departamento",-40.1487161833477,-64.3048926460226],
  ["Departamento Sargento Cabral","Sargento Cabral","22154","22","Departamento",-26.8016874124461,-59.5196519224863],
  ["Departamento Independencia","Independencia","22070","22","Departamento",-26.736996206931,-60.7570241668236],
  ["Departamento Mayor Luis J. Fontana","Mayor Luis J. Fontana","22098","22","Departamento",-27.7436812830101,-60.6581451476891],
  ["Departamento Fray Justo Santa María de Oro","Fray Justo Santa María de Oro","22043","22","Departamento",-27.8662498172761,-61.300959824592],
  ["Departamento 1° de Mayo","1° de Mayo","22126","22","Departamento",-27.1691720457957,-58.9595089153944],
  ["Departamento Ayacucho","Ayacucho","74007","74","Departamento",-32.1656565638277,-66.5422509844147],
  ["Partido de Maipú","Maipú","06511","06","Partido",-36.8865728387855,-57.586173153195],
  ["Departamento 12 de Octubre","12 de Octubre","22036","22","Departamento",-27.3362384898477,-61.4747691940114],
  ["Departamento Santa María","Santa María","14147","14","Departamento",-31.7112016051317,-64.3070593086884],
  ["Departamento San Alberto","San Alberto","14126","14","Departamento",-31.707791961138,-65.1564069990554],
  ["Departamento Río Segundo","Río Segundo","14119","14","Departamento",-31.7330269369319,-63.4769207987931],
  ["Departamento San Justo","San Justo","14140","14","Departamento",-31.2393990103815,-62.5260292405918],
  ["Departamento Unión","Unión","14182","14","Departamento",-32.8784545187661,-62.7914258058015],
  ["Departamento Tercero Arriba","Tercero Arriba","14161","14","Departamento",-32.2877127172928,-63.7792479671775],
  ["Departamento Cerrillos","Cerrillos","66035","66","Departamento",-24.9885518325631,-65.4038423380142],
  ["Departamento Río Cuarto","Río Cuarto","14098","14","Departamento",-33.3308032176015,-64.494180483748],
  ["Departamento Tupungato","Tupungato","50126","50","Departamento",-33.2915070191465,-69.3019667535127],
  ["Departamento Pilagás","Pilagás","34042","34","Departamento",-25.1053773070169,-58.6616277482245],
  ["Departamento Laishí","Laishí","34021","34","Departamento",-26.467587999102,-58.5654369092882],
  ["Departamento Pirané","Pirané","34056","34","Departamento",-25.7672893097833,-59.1592573575224],
  ["Departamento General Güemes","General Güemes","22063","22","Departamento",-25.2137925689732,-61.337579887251],
  ["Departamento Ñorquinco","Ñorquinco","62056","62","Departamento",-41.7398257356123,-70.4011139544739],
  ["Partido de Adolfo Alsina","Adolfo Alsina","06007","06","Partido",-37.1963357906582,-63.0560072843652],
  ["Partido de Puán","Puán","06651","06","Partido",-38.0746044477032,-63.0577463401906],
  ["Partido de Villarino","Villarino","06875","06","Partido",-39.1296648457138,-62.7268024308429],
  ["Departamento Presidente Roque Sáenz Peña","Presidente Roque Sáenz Peña","14084","14","Departamento",-34.1401111180237,-63.4187744697841],
  ["Partido de General Villegas","General Villegas","06392","06","Partido",-34.7687371057529,-62.9535454567251],
  ["Departamento General Roca","General Roca","14035","14","Departamento",-34.6170744283348,-64.3787603319835],
  ["Departamento General Alvear","General Alvear","50014","50","Departamento",-35.2178364156832,-67.0804473289428],
  ["Departamento Río Hondo","Río Hondo","86147","86","Departamento",-27.4854057246231,-64.7601873654679],
  ["Partido de San Pedro","San Pedro","06770","06","Partido",-33.7819425849294,-59.7825917634816],
  ["Departamento Rivadavia","Rivadavia","66133","66","Departamento",-23.5128446678353,-62.8303776832343],
  ["Departamento Rosario de Lerma","Rosario de Lerma","66147","66","Departamento",-24.5462867797822,-65.8530871719889],
  ["Departamento Ledesma","Ledesma","38035","38","Departamento",-23.7855349092159,-64.8287565421131],
  ["Departamento Capital","Capital","18021","18","Departamento",-27.522187514513,-58.7627061875969],
  ["Departamento Capital","Capital","54028","54","Departamento",-27.5507848284827,-55.856845031149],
  ["Departamento Iguazú","Iguazú","54063","54","Departamento",-25.8747354912768,-54.4004185891377],
  ["Departamento Oberá","Oberá","54091","54","Departamento",-27.4763636003081,-55.0712221116124],
  ["Departamento San Ignacio","San Ignacio","54098","54","Departamento",-27.1765939564162,-55.3392901890006],
  ["Departamento Capital","Capital","46014","46","Departamento",-29.4604898579358,-66.3525089002799],
  ["Departamento Río Seco","Río Seco","14112","14","Departamento",-30.032189401961,-63.2238214757827],
  ["Departamento Avellaneda","Avellaneda","62014","62","Departamento",-39.4101860186287,-66.2062591058801],
  ["Departamento General Roca","General Roca","62042","62","Departamento",-38.5324900624312,-67.554484164455],
  ["Departamento San Fernando","San Fernando","22140","22","Departamento",-27.7160106963678,-59.1157493078992],
  ["Departamento Belgrano","Belgrano","74014","74","Departamento",-32.7356115411335,-66.7150069507327],
  ["Departamento Los Lagos","Los Lagos","58070","58","Departamento",-40.7743899197092,-71.4866965761944],
  ["Departamento Belén","Belén","10035","10","Departamento",-27.1000545044873,-66.9223774125099],
  ["Departamento Confluencia","Confluencia","58035","58","Departamento",-38.8325294845843,-68.7930144598811],
  ["Departamento Picunches","Picunches","58105","58","Departamento",-38.5742697933456,-70.3729347665806],
  ["Departamento Añelo","Añelo","58014","58","Departamento",-38.0986455753996,-69.0127575196277],
  ["Departamento Loncopué","Loncopué","58063","58","Departamento",-38.0659054264443,-70.3140568384535],
  ["Departamento Ñorquín","Ñorquín","58084","58","Departamento",-37.6378798941082,-70.6777764142853],
  ["Departamento Capital","Capital","10049","10","Departamento",-28.4104559393629,-65.8362002957174],
  ["Departamento Ancasti","Ancasti","10014","10","Departamento",-28.9266675681635,-65.5038083174841],
  ["Departamento Pehuenches","Pehuenches","58091","58","Departamento",-37.3984401348449,-69.4019520980894],
  ["Departamento Minas","Minas","58077","58","Departamento",-36.8583892643308,-70.7836605070546],
  ["Departamento Chos Malal","Chos Malal","58042","58","Departamento",-36.8804936082292,-70.2862810211876],
  ["Departamento Cushamen","Cushamen","26014","26","Departamento",-42.36635302228,-70.7120117319755],
  ["Departamento Lago Buenos Aires","Lago Buenos Aires","78035","78","Departamento",-46.8341030724218,-70.6314100141799],
  ["Comuna 2","Comuna 2","02014","02","Comuna",-34.5857649937965,-58.3948918118195],
  ["Comuna 8","Comuna 8","02056","02","Comuna",-34.6745676187442,-58.461944281059],
  ["Departamento Ramón Lista","Ramón Lista","34063","34","Departamento",-23.1201560396969,-62.1382049441497],
  ["Departamento Sobremonte","Sobremonte","14154","14","Departamento",-29.7654579620613,-64.1428878947488],
  ["Departamento Banda","Banda","86035","86","Departamento",-27.4347067679294,-64.2098658068888],
  ["Partido de Chivilcoy","Chivilcoy","06224","06","Partido",-34.9157089757004,-59.9584822196811],
  ["Departamento Villa Constitución","Villa Constitución","82028","82","Departamento",-33.4855834326751,-60.85138406701],
  ["Departamento Mártires","Mártires","26063","26","Departamento",-43.8138432526407,-67.2400230074032],
  ["Departamento Sarmiento","Sarmiento","86182","86","Departamento",-28.1061147414005,-63.4461751488674],
  ["Departamento Deseado","Deseado","78014","78","Departamento",-47.3305185775707,-68.0290787062148],
  ["Departamento Languiñeo","Languiñeo","26056","26","Departamento",-43.3234947781653,-70.3484257364086],
  ["Departamento Belgrano","Belgrano","86042","86","Departamento",-29.0813959929051,-62.2187677325403],
  ["Departamento Aguirre","Aguirre","86007","86","Departamento",-29.2978682731406,-62.5153416521407],
  ["Comuna 14","Comuna 14","02098","02","Comuna",-34.5738372943158,-58.4222211632133],
  ["Departamento Guasayán","Guasayán","86084","86","Departamento",-27.9767710254958,-64.8711532150043],
  ["Departamento Capital","Capital","14014","14","Departamento",-31.4170686019036,-64.1832168468628],
  ["Departamento Antofagasta de la Sierra","Antofagasta de la Sierra","10028","10","Departamento",-25.9455797002151,-67.6777645009401],
  ["Departamento San Carlos","San Carlos","50091","50","Departamento",-34.0753663960754,-69.0977010128957],
  ["Departamento Futaleufú","Futaleufú","26035","26","Departamento",-43.070540741803,-71.4553756889394],
  ["Departamento Río Chico","Río Chico","78049","78","Departamento",-48.2873290186499,-71.1138374982594],
  ["Departamento Lago Argentino","Lago Argentino","78028","78","Departamento",-49.8364881431632,-72.0654713338211],
  ["Departamento El Cuy","El Cuy","62035","62","Departamento",-39.7016431663172,-68.4845953824055],
  ["Departamento Las Heras","Las Heras","50049","50","Departamento",-32.5247668775446,-69.26717572394],
  ["Departamento Lavalle","Lavalle","50056","50","Departamento",-32.582585367751,-67.8890727049671],
  ["Departamento Pichi Mahuida","Pichi Mahuida","62063","62","Departamento",-39.4076832777441,-64.4005868582138],
  ["Departamento Adolfo Alsina","Adolfo Alsina","62007","62","Departamento",-40.7917543082478,-63.765086491035],
  ["Comuna 3","Comuna 3","02021","02","Comuna",-34.6138430816863,-58.4026514512217],
  ["Departamento Capital","Capital","86049","86","Departamento",-27.8847652276316,-64.4356675404002],
  ["Partido de General Alvear","General Alvear","06287","06","Partido",-36.0345220351902,-60.1333612561516],
  ["Departamento Loreto","Loreto","86105","86","Departamento",-28.6244804367569,-64.3107274308234],
  ["Departamento Villaguay","Villaguay","30113","30","Departamento",-31.6477388963494,-59.0594708104081],
  ["Partido de Castelli","Castelli","06168","06","Partido",-36.041669400313,-57.6570625692977],
  ["Departamento San Salvador","San Salvador","30088","30","Departamento",-31.5768835387468,-58.4863728567996],
  ["Partido de Almirante Brown","Almirante Brown","06028","06","Partido",-34.8355700988623,-58.3673978494737],
  ["Departamento Nogoyá","Nogoyá","30077","30","Departamento",-32.2187123475252,-59.7697019155424],
  ["Departamento Tala","Tala","30091","30","Departamento",-32.3174117217417,-59.2672864855269],
  ["Departamento La Paz","La Paz","30070","30","Departamento",-30.8974563498339,-59.5004488104579],
  ["Departamento San Lorenzo","San Lorenzo","22147","22","Departamento",-27.3950475960133,-60.3646185068028],
  ["Partido de La Plata","La Plata","06441","06","Partido",-35.0034938070318,-58.0180274992052],
  ["Partido de Brandsen","Brandsen","06119","06","Partido",-35.2221104711751,-58.1760719473086],
  ["Partido de 25 de Mayo","25 de Mayo","06854","06","Partido",-35.5265113228112,-60.2301576569223],
  ["Partido de Pehuajó","Pehuajó","06609","06","Partido",-35.8833833438579,-61.9271985156994],
  ["Partido de General Belgrano","General Belgrano","06301","06","Partido",-35.8349745328235,-58.6980461310919],
  ["Departamento Capayán","Capayán","10042","10","Departamento",-28.9092326420174,-65.9015706538014],
  ["Partido de Monte","Monte","06547","06","Partido",-35.5103702936319,-58.7694635013319],
  ["Partido de Roque Pérez","Roque Pérez","06693","06","Partido",-35.4811110714388,-59.3595940527063],
  ["Partido de Pilar","Pilar","06638","06","Partido",-34.4481990221196,-58.9034413925773],
  ["Partido de Luján","Luján","06497","06","Partido",-34.5676194636906,-59.1585123543241],
  ["Partido de Azul","Azul","06049","06","Partido",-36.7857719233293,-59.69665215894],
  ["Departamento Concepción","Concepción","54035","54","Departamento",-27.9311673936983,-55.4670364911295],
  ["Partido de Merlo","Merlo","06539","06","Partido",-34.7108867791705,-58.7418777656329],
  ["Partido de Chacabuco","Chacabuco","06210","06","Partido",-34.6184039263126,-60.3539279007252],
  ["Partido de Carmen de Areco","Carmen de Areco","06161","06","Partido",-34.4067983092213,-59.8842434040917],
  ["Partido de General Rodríguez","General Rodríguez","06364","06","Partido",-34.6503494927057,-58.9879503249052],
  ["Partido de Exaltación de la Cruz","Exaltación de la Cruz","06266","06","Partido",-34.2951491690699,-59.1559117007684],
  ["Partido de San Miguel","San Miguel","06760","06","Partido",-34.5520919648351,-58.6917055208826],
  ["Partido de San Andrés de Giles","San Andrés de Giles","06728","06","Partido",-34.4377851586384,-59.4732938848478],
  ["Partido de Junín","Junín","06413","06","Partido",-34.546128336039,-61.0054940705488],
  ["Partido de Marcos Paz","Marcos Paz","06525","06","Partido",-34.8137199832046,-58.8480634347315],
  ["Departamento Juárez Celman","Juárez Celman","14056","14","Departamento",-33.329445846674,-63.6063356482423],
  ["Departamento Lihuel Calel","Lihuel Calel","42084","42","Departamento",-38.2616553827262,-65.0966303997922],
  ["Partido de Mercedes","Mercedes","06532","06","Partido",-34.6971944325993,-59.42081198401],
  ["Departamento 2 de Abril","2 de Abril","22039","22","Departamento",-27.6219112869485,-61.3295201872432],
  ["Partido de Hurlingham","Hurlingham","06408","06","Partido",-34.5992140053733,-58.6496943606349],
  ["Partido de Morón","Morón","06568","06","Partido",-34.6491410653179,-58.6198433488168],
  ["Partido de Ciudad Libertador San Martín","Ciudad Libertador San Martín","06371","06","Partido",-34.5526490761118,-58.5643145358763],
  ["Departamento La Candelaria","La Candelaria","66084","66","Departamento",-26.0838657971757,-65.1765900958914],
  ["Partido de Ituzaingó","Ituzaingó","06410","06","Partido",-34.6360018167543,-58.6887583352667],
  ["Departamento La Capital","La Capital","82063","82","Departamento",-31.4753563662874,-60.6694790125744],
  ["Departamento Santo Tomé","Santo Tomé","18168","18","Departamento",-28.2311093523606,-56.222206072693],
  ["Departamento Saladas","Saladas","18126","18","Departamento",-28.2124729464641,-58.6199065693295],
  ["Departamento General Paz","General Paz","18063","18","Departamento",-27.7199243812297,-57.7876196199145],
  ["Partido de Suipacha","Suipacha","06784","06","Partido",-34.7485629683304,-59.7034737442182],
  ["Partido de Tres de Febrero","Tres de Febrero","06840","06","Partido",-34.5959797363173,-58.5790926022347],
  ["Departamento Coronel Felipe Varela","Coronel Felipe Varela","46028","46","Departamento",-29.449795605204,-68.3284822964489],
  ["Partido de Alberti","Alberti","06021","06","Partido",-35.0363817959326,-60.2828693081193],
  ["Partido de Lanús","Lanús","06434","06","Partido",-34.7057824914432,-58.3954484986693],
  ["Partido de General Las Heras","General Las Heras","06329","06","Partido",-34.9094258328137,-58.9958733938567],
  ["Partido de Lomas de Zamora","Lomas de Zamora","06490","06","Partido",-34.7554708441214,-58.424078867213],
  ["Partido de Navarro","Navarro","06574","06","Partido",-35.0304083582525,-59.429785480408],
  ["Partido de Cañuelas","Cañuelas","06134","06","Partido",-35.1450252367714,-58.6907790273655],
  ["Departamento Guachipas","Guachipas","66063","66","Departamento",-25.7029508773623,-65.4445360285708],
  ["Departamento Cafayate","Cafayate","66021","66","Departamento",-26.1255099823638,-65.8800888963475],
  ["Partido de Lobos","Lobos","06483","06","Partido",-35.2195598528609,-59.1458071242931],
  ["Partido de Quilmes","Quilmes","06658","06","Partido",-34.7350141996909,-58.2768874201614],
  ["Partido de Pila","Pila","06630","06","Partido",-36.2023512628961,-58.3408970254988],
  ["Partido de General La Madrid","General La Madrid","06322","06","Partido",-37.3557097661663,-61.3442438803068],
  ["Partido de San Bolívar","Bolívar","06105","06","Partido",-36.2982217499893,-61.1496836148108],
  ["Partido de Balcarce","Balcarce","06063","06","Partido",-37.7142728188627,-58.2720776945726],
  ["Partido de Hipólito Yrigoyen","Hipólito Yrigoyen","06406","06","Partido",-36.2593312232241,-61.6600936665535],
  ["Partido de Dolores","Dolores","06238","06","Partido",-36.3986615531875,-57.6326112997092],
  ["Partido de Tres Lomas","Tres Lomas","06847","06","Partido",-36.4973152716526,-62.8634418902354],
  ["Partido de Ayacucho","Ayacucho","06042","06","Partido",-37.0347821696395,-58.442581327328],
  ["Departamento Bella Vista","Bella Vista","18007","18","Departamento",-28.4973936042369,-58.930436271179],
  ["Departamento Tapenagá","Tapenagá","22161","22","Departamento",-27.6598759889301,-59.8288687407326],
  ["Departamento Concordia","Concordia","30015","30","Departamento",-31.2902983723403,-58.237869689912],
  ["Departamento Federal","Federal","30035","30","Departamento",-30.9924267797136,-58.8918600477837],
  ["Departamento Gualeguaychú","Gualeguaychú","30056","30","Departamento",-33.0223492433906,-58.7857904865089],
  ["Departamento Islas del Ibicuy","Islas del Ibicuy","30063","30","Departamento",-33.6241288152628,-58.9351580556436],
  ["Partido de General Pinto","General Pinto","06351","06","Partido",-34.6683135254839,-62.0397484845208],
  ["Partido de Guaminí","Guaminí","06399","06","Partido",-36.8905500665858,-62.4187740896092],
  ["Partido de Avellaneda","Avellaneda","06035","06","Partido",-34.6782056572194,-58.341116892125],
  ["Departamento Calingasta","Calingasta","70021","70","Departamento",-31.453365238609,-69.8338001250755],
  ["Departamento 25 de Mayo","25 de Mayo","70126","70","Departamento",-31.9896198487776,-67.8274038981039],
  ["Partido de Colón","Colón","06175","06","Partido",-33.8860220920375,-61.0633674925405],
  ["Partido de San Cayetano","San Cayetano","06742","06","Partido",-38.3886180658492,-59.5866369475028],
  ["Partido de Tres Arroyos","Tres Arroyos","06833","06","Partido",-38.5116665533312,-60.2376664741026],
  ["Departamento Figueroa","Figueroa","86070","86","Departamento",-27.3218567500252,-63.5796320220819],
  ["Partido de Saavedra","Saavedra","06700","06","Partido",-37.7710550160995,-62.4351452974673],
  ["Partido de Monte Hermoso","Monte Hermoso","06553","06","Partido",-38.96257223668,-61.2904738793276],
  ["Partido de Lobería","Lobería","06476","06","Partido",-38.0897033467581,-58.6939656644915],
  ["Partido de Berisso","Berisso","06098","06","Partido",-34.909463480255,-57.8283887071779],
  ["Partido de Tordillo","Tordillo","06812","06","Partido",-36.3908002975414,-57.2746828657242],
  ["Partido de Ramallo","Ramallo","06665","06","Partido",-33.5872972390017,-60.0574845905723],
  ["Partido de San Nicolás","San Nicolás","06763","06","Partido",-33.4825541340452,-60.292953731623],
  ["Departamento Moreno","Moreno","86119","86","Departamento",-27.2981373849478,-62.4633306370511],
  ["Partido de General Guido","General Guido","06308","06","Partido",-36.6659831488299,-57.9957841120045],
  ["Departamento Chacabuco","Chacabuco","22028","22","Departamento",-27.1179308909271,-61.3088910569936],
  ["Departamento Guaymallén","Guaymallén","50028","50","Departamento",-32.8910429154042,-68.7323728513948],
  ["Departamento Capital","Capital","66028","66","Departamento",-24.8902273126574,-65.2702656216248],
  ["Departamento 25 de Mayo","25 de Mayo","22168","22","Departamento",-26.8190298006571,-60.0187693847422],
  ["Partido de Coronel Suárez","Coronel Suárez","06203","06","Partido",-37.5325532169014,-61.8893137767698],
  ["Partido de Coronel Dorrego","Coronel Dorrego","06189","06","Partido",-38.6704811465081,-61.0956539726773],
  ["Partido de Necochea","Necochea","06581","06","Partido",-38.2555189703716,-59.1673660597249],
  ["Departamento Independencia","Independencia","46105","46","Departamento",-30.1144612462884,-67.3355202231145],
  ["Departamento Maipú","Maipú","50070","50","Departamento",-32.9775099458466,-68.6521739904164],
  ["Departamento Capital","Capital","50007","50","Departamento",-32.8806541047985,-68.8921657602392],
  ["Departamento Godoy Cruz","Godoy Cruz","50021","50","Departamento",-32.9297600556689,-68.8890844545155],
  ["Departamento Andalgalá","Andalgalá","10021","10","Departamento",-27.5445087646164,-66.3560062057426],
  ["Departamento Ambato","Ambato","10007","10","Departamento",-28.0189344685483,-65.9222983796596],
  ["Partido de Bahía Blanca","Bahía Blanca","06056","06","Partido",-38.5808546732895,-62.1656895327094],
  ["Partido de General Alvarado","General Alvarado","06280","06","Partido",-38.2027130466251,-58.0722485722113],
  ["Partido de General Pueyrredón","General Pueyrredón","06357","06","Partido",-37.9656760017008,-57.743144039076],
  ["Partido de Mar Chiquita","Mar Chiquita","06518","06","Partido",-37.4984341235843,-57.6436183302355],
  ["Partido de Villa Gesell","Villa Gesell","06868","06","Partido",-37.3705193886837,-57.0658445979783],
  ["Departamento Junín","Junín","50035","50","Departamento",-33.1462075241433,-68.4803420038399],
  ["Departamento Castro Barros","Castro Barros","46021","46","Departamento",-28.8599829479001,-66.9185847556269],
  ["Departamento Quitilipi","Quitilipi","22133","22","Departamento",-26.6685132272644,-60.1735021538447],
  ["Partido de Pinamar","Pinamar","06644","06","Partido",-37.1099458706882,-56.8696753966329],
  ["Partido de General Lavalle","General Lavalle","06336","06","Partido",-36.6518890129521,-56.9422695810513],
  ["Partido de La Costa","La Costa","06420","06","Partido",-36.6782018297724,-56.7189105094625],
  ["Partido de Magdalena","Magdalena","06505","06","Partido",-35.1849498629024,-57.6863916156026],
  ["Departamento Sanagasta","Sanagasta","46126","46","Departamento",-29.1585269700688,-67.0658836337793],
  ["Partido de Vicente López","Vicente López","06861","06","Partido",-34.5265131808416,-58.5044695897767],
  ["Departamento Chilecito","Chilecito","46042","46","Departamento",-29.3959374753391,-67.4278867891974],
  ["Departamento Presidencia de la Plaza","Presidencia de la Plaza","22119","22","Departamento",-27.0468199682862,-59.7751691822068],
  ["Departamento Victoria","Victoria","30105","30","Departamento",-32.7839424597327,-60.2180700309804],
  ["Departamento General Ángel V. Peñaloza","General Ángel V. Peñaloza","46056","46","Departamento",-30.3128975389814,-66.6630521188972],
  ["Departamento Diamante","Diamante","30021","30","Departamento",-32.228040548998,-60.5239335894137],
  ["Departamento Uruguay","Uruguay","30098","30","Departamento",-32.4499666887673,-58.5822661421638],
  ["Departamento Paraná","Paraná","30084","30","Departamento",-31.6952294494435,-60.041174481445],
  ["Partido de Saladillo","Saladillo","06707","06","Partido",-35.6765966680226,-59.7037033020054],
  ["Partido de Las Flores","Las Flores","06455","06","Partido",-36.0157017377305,-59.1769657671576],
  ["Partido de Rojas","Rojas","06686","06","Partido",-34.1926035952586,-60.7879706568364],
  ["Partido de Escobar","Escobar","06252","06","Partido",-34.3287181500871,-58.7711281467385],
  ["Partido de Pergamino","Pergamino","06623","06","Partido",-33.835815535365,-60.5450748689588],
  ["Departamento General Juan F. Quiroga","General Juan F. Quiroga","46070","46","Departamento",-30.800959034536,-66.868104514456],
  ["Departamento Lules","Lules","90063","90","Departamento",-26.8624408970891,-65.4310597836071],
  ["Departamento Yerba Buena","Yerba Buena","90119","90","Departamento",-26.7861906133402,-65.3424091314535],
  ["Departamento Tafí Viejo","Tafí Viejo","90105","90","Departamento",-26.6607281369398,-65.4634432127741],
  ["Departamento Burruyacú","Burruyacú","90007","90","Departamento",-26.5309358872581,-64.8198149704644],
  ["Departamento Rosario Vera Peñaloza","Rosario Vera Peñaloza","46112","46","Departamento",-31.4205977732086,-66.6788621651991],
  ["Departamento Vera","Vera","82133","82","Departamento",-28.9699286424835,-60.4135430497849],
  ["Departamento 9 de Julio","9 de Julio","82077","82","Departamento",-28.849605091735,-61.3983535538115],
  ["Departamento Iglesia","Iglesia","70049","70","Departamento",-29.6066873518726,-69.437949892691],
  ["Departamento Valle Fértil","Valle Fértil","70119","70","Departamento",-30.7122962694155,-67.5323035648395],
  ["Departamento Ullum","Ullum","70112","70","Departamento",-31.0904647062097,-68.8815821606005],
  ["Departamento Albardón","Albardón","70007","70","Departamento",-31.2096344810555,-68.4519807662306],
  ["Departamento Zonda","Zonda","70133","70","Departamento",-31.6381980593912,-68.9555709233027],
  ["Departamento Gobernador Dupuy","Gobernador Dupuy","74042","74","Departamento",-35.369087077487,-65.8148193795656],
  ["Departamento Cachi","Cachi","66014","66","Departamento",-25.038234468241,-66.2030292859746],
  ["Departamento Chicoana","Chicoana","66042","66","Departamento",-25.1514718801816,-65.6059279182319],
  ["Departamento La Viña","La Viña","66098","66","Departamento",-25.4475878403232,-65.5807612448506],
  ["Partido de Rauch","Rauch","06672","06","Partido",-36.5722509524193,-58.9444061302172],
  ["Departamento Metán","Metán","66112","66","Departamento",-25.4251673018384,-64.588141248868],
  ["Departamento Molinos","Molinos","66119","66","Departamento",-25.5643605125424,-66.4549057919868],
  ["Partido de Salliqueló","Salliqueló","06721","06","Partido",-36.6710137553167,-63.0491259803334],
  ["Partido de Berazategui","Berazategui","06091","06","Partido",-34.8179736855733,-58.1552626920478],
  ["Departamento General Güemes","General Güemes","66049","66","Departamento",-24.7648231076768,-64.9560952507157],
  ["Departamento San Carlos","San Carlos","66154","66","Departamento",-25.8276863599322,-66.1742423008628],
  ["Departamento Rancul","Rancul","42126","42","Departamento",-35.4015889145024,-64.8014904385407],
  ["Departamento Conhelo","Conhelo","42035","42","Departamento",-36.0315435775022,-64.5106030260375],
  ["Departamento Fray Mamerto Esquiú","Fray Mamerto Esquiú","10063","10","Departamento",-28.3329401551221,-65.7309008581155],
  ["Departamento General Ocampo","General Ocampo","46084","46","Departamento",-31.0066417359043,-66.0590548632025],
  ["Partido de Presidente Perón","Presidente Perón","06648","06","Partido",-34.9298313021932,-58.398091246683],
  ["Departamento 9 de julio","9 de julio","62049","62","Departamento",-40.9256367295503,-67.4574905887938],
  ["Departamento General San Martín","General San Martín","46091","46","Departamento",-31.6413069709194,-66.1459756728153],
  ["Departamento Atamisqui","Atamisqui","86021","86","Departamento",-28.6918181694465,-63.8815639978494],
  ["Partido de Coronel de Marina Leonardo Rosales","Coronel de Marina Leonardo Rosales","06182","06","Partido",-38.8488346485235,-61.8360446581448],
  ["Departamento Famatina","Famatina","46049","46","Departamento",-28.6973037998771,-67.5592920371088],
  ["Departamento Libertad","Libertad","22077","22","Departamento",-27.3511465491091,-59.2606339567401],
  ["Departamento Río Grande","Tolhuin","94011","94","Departamento",-54.4245608958778,-67.5034849431886],
  ["Departamento San Blas de Los Sauces","San Blas de Los Sauces","46119","46","Departamento",-28.5433309063736,-67.1581530651936],
  ["Departamento Garay","Garay","82035","82","Departamento",-31.0546413323001,-60.125807734045],
  ["Departamento Las Colonias","Las Colonias","82070","82","Departamento",-31.3153379046182,-61.1094808024842],
  ["Departamento Realicó","Realicó","42133","42","Departamento",-35.2257917366713,-64.2102269263624],
  ["Departamento Formosa","Formosa","34014","34","Departamento",-25.9396352318956,-58.3773174492554],
  ["Departamento Paclín","Paclín","10077","10","Departamento",-28.1100496216627,-65.6738760483046],
  ["Departamento El Alto","El Alto","10056","10","Departamento",-28.430382930044,-65.3599245662077],
  ["Departamento Comandante Fernández","Comandante Fernández","22021","22","Departamento",-26.7871365610548,-60.4618654287039],
  ["Partido de Leandro N. Alem","Leandro N. Alem","06462","06","Partido",-34.4979563497613,-61.61293092454],
  ["Departamento General Belgrano","General Belgrano","22049","22","Departamento",-26.849534277685,-61.071967717894],
  ["Departamento General Donovan","General Donovan","22056","22","Departamento",-27.1409287639679,-59.3474877785089],
  ["Departamento Tehuelches","Tehuelches","26098","26","Departamento",-44.2000353406651,-70.5768950488331],
  ["Departamento Escalante","Escalante","26021","26","Departamento",-45.282788434735,-67.7087570024311],
  ["Departamento Ischilín","Ischilín","14049","14","Departamento",-30.3997182320053,-64.6094899792791],
  ["Departamento Totoral","Totoral","14168","14","Departamento",-30.7261313372803,-63.9842524222316],
  ["Departamento General San Martín","General San Martín","14042","14","Departamento",-32.5143341151357,-63.2562237062848],
  ["Departamento San Javier","San Javier","14133","14","Departamento",-32.0753882467214,-65.1421073770609],
  ["Partido de General Arenales","General Arenales","06294","06","Partido",-34.237459671314,-61.2838006242346],
  ["Partido de Rivadavia","Rivadavia","06679","06","Partido",-35.5809627302368,-63.0945777162156],
  ["Comuna 9","Comuna 9","02063","02","Comuna",-34.6517602348111,-58.4991151516538],
  ["Departamento Angaco","Angaco","70014","70","Departamento",-31.1922192642063,-68.1319625798128],
  ["Departamento Caucete","Caucete","70035","70","Departamento",-31.506381702579,-67.5458594420512],
  ["Departamento Picún Leufú","Picún Leufú","58098","58","Departamento",-39.4039894660668,-69.4271919918532],
  ["Departamento Aluminé","Aluminé","58007","58","Departamento",-39.1314863536049,-71.0463179632497],
  ["Departamento Sarmiento","Sarmiento","26091","26","Departamento",-45.3450235273933,-69.0028353555711],
  ["Partido de General Paz","General Paz","06343","06","Partido",-35.4662020729313,-58.3900057061752],
  ["Departamento San Miguel","San Miguel","18154","18","Departamento",-27.8758228176186,-57.409985810344],
  ["Comuna 7","Comuna 7","02049","02","Comuna",-34.6365544143719,-58.4518868569844],
  ["Departamento 25 de Mayo","25 de Mayo","62091","62","Departamento",-41.1330823086991,-68.9063154547507],
  ["Comuna 10","Comuna 10","02070","02","Comuna",-34.6278516942726,-58.5028179980211],
  ["Departamento Antártida Argentina","Antártida Argentina","94028","94","Departamento",-82.7834172335301,-50.6450428018267],
  ["Departamento Islas del Atlántico Sur","Islas del Atlántico Sur","94021","94","Departamento",-52.8527307050346,-53.0409118433889],
  ["Departamento Telsen","Telsen","26105","26","Departamento",-42.4389445468027,-67.1769071477022],
  ["Comuna 11","Comuna 11","02077","02","Comuna",-34.6061369839531,-58.4967418386195],
  ["Partido de San Antonio de Areco","San Antonio de Areco","06735","06","Partido",-34.2206591685119,-59.5193792218302],
  ["Partido de Moreno","Moreno","06560","06","Partido",-34.610617117824,-58.8109232680035],
  ["Partido de La Matanza","La Matanza","06427","06","Partido",-34.7701647288569,-58.6254486939189],
  ["Departamento Pilcaniyeu","Pilcaniyeu","62070","62","Departamento",-40.8875778145279,-70.4626919728142],
  ["Departamento Ojo de Agua","Ojo de Agua","86126","86","Departamento",-29.3040900587554,-64.0149932737063],
  ["Partido de Lezama","Lezama","06466","06","Partido",-35.8494190496267,-57.89575256553],
  ["Partido de Punta Indio","Punta Indio","06655","06","Partido",-35.4261581087913,-57.3996034519105],
  ["Departamento El Carmen","El Carmen","38014","38","Departamento",-24.447823040536,-65.1011266142907],
  ["Departamento Santa María","Santa María","10091","10","Departamento",-26.7859032829476,-66.2618848691237],
  ["Departamento Gaiman","Gaiman","26042","26","Departamento",-43.2727624456965,-66.172162203297],
  ["Departamento General Lamadrid","General Lamadrid","46077","46","Departamento",-28.7904353562793,-68.6977547342214],
  ["Departamento Pocho","Pocho","14077","14","Departamento",-31.4634407170853,-65.4384772539188],
  ["Departamento Goya","Goya","18070","18","Departamento",-29.4514531616824,-59.255912536825],
  ["Departamento Lavalle","Lavalle","18091","18","Departamento",-28.9879963080686,-58.9337155943843],
  ["Departamento San Roque","San Roque","18161","18","Departamento",-28.7057979959044,-58.6130197699847],
  ["Comuna 6","Comuna 6","02042","02","Comuna",-34.6168433901108,-58.4435682280605],
  ["Departamento Tulumba","Tulumba","14175","14","Departamento",-30.2222689247998,-63.8118051923902],
  ["Departamento Cruz del Eje","Cruz del Eje","14028","14","Departamento",-30.6580631596452,-65.0774738750322],
  ["Departamento Punilla","Punilla","14091","14","Departamento",-31.2225592168079,-64.5861516801457],
  ["Departamento Minas","Minas","14070","14","Departamento",-31.0355515814319,-65.4111896095111],
  ["Departamento Valcheta","Valcheta","62084","62","Departamento",-40.9745810611866,-66.3108866018754],
  ["Departamento San Antonio","San Antonio","62077","62","Departamento",-40.9527925288953,-65.3712468150427],
  ["Partido de Pellegrini","Pellegrini","06616","06","Partido",-36.2709141317271,-63.2257388675861],
  ["Departamento 9 de Julio","9 de Julio","22105","22","Departamento",-26.9455386975653,-61.2652576678175],
  ["Departamento La Caldera","La Caldera","66077","66","Departamento",-24.5623945143611,-65.4300986417702],
  ["Departamento San Rafael","San Rafael","50105","50","Departamento",-34.9445449681903,-68.3826783125854],
  ["Departamento Anta","Anta","66007","66","Departamento",-24.8751339637689,-63.8400961373676],
  ["Departamento General Belgrano","General Belgrano","46063","46","Departamento",-30.5776916502152,-65.9316310510947],
  ["Departamento Copo","Copo","86056","86","Departamento",-25.9392514746819,-62.7304991775974],
  ["Departamento Vinchina","Vinchina","46098","46","Departamento",-28.3164203776524,-68.525398463115],
  ["Departamento Lácar","Lácar","58056","58","Departamento",-40.3142303514009,-71.1842517277166],
  ["Comuna 13","Comuna 13","02091","02","Comuna",-34.5542357921934,-58.4540058768299],
  ["Departamento Güer Aike","Güer Aike","78021","78","Departamento",-51.4134125040273,-70.5618155470895],
  ["Departamento Río Grande","Río Grande","94008","94","Departamento",-53.7462919872259,-68.1361046546959],
  ["Departamento Ushuaia","Ushuaia","94015","94","Departamento",-54.7704623704114,-66.6837162279656],
  ["Departamento Malargüe","Malargüe","50077","50","Departamento",-36.1572730441871,-69.3135099463311],
  ["Departamento Pomán","Pomán","10084","10","Departamento",-28.2055993966253,-66.4072986488285],
  ["Departamento Graneros","Graneros","90035","90","Departamento",-27.713461665638,-65.2554821697556],
  ["Departamento Rosario de la Frontera","Rosario de la Frontera","66140","66","Departamento",-25.8718676537564,-64.7278906135036],
  ["Departamento Paso de Indios","Paso de Indios","26070","26","Departamento",-44.0301843800804,-68.6858628378391],
  ["Departamento Almirante Brown","Almirante Brown","22007","22","Departamento",-25.747858341484,-61.9605236304385],
  ["Departamento Valle Viejo","Valle Viejo","10112","10","Departamento",-28.5987132205968,-65.7071834454567],
  ["Departamento Maipú","Maipú","22091","22","Departamento",-26.3210291409673,-60.4553482590556],
  ["Departamento Robles","Robles","86161","86","Departamento",-27.8539440726125,-63.9075092603179],
  ["Departamento Colón","Colón","30008","30","Departamento",-32.0114827529012,-58.3699129592754],
  ["Departamento Tunuyán","Tunuyán","50119","50","Departamento",-33.6223342938194,-69.5078054633807],
  ["Departamento Luján de Cuyo","Luján de Cuyo","50063","50","Departamento",-33.0382520812765,-69.4437142136667],
  ["Departamento Río Senguer","Río Senguer","26084","26","Departamento",-45.3403562037762,-70.6400981523958],
  ["Departamento Bariloche","Bariloche","62021","62","Departamento",-41.4981211976981,-71.531077517069],
  ["Departamento Huiliches","Huiliches","58049","58","Departamento",-39.7946776781363,-71.2590025540125],
  ["Departamento Catán Lil","Catán Lil","58021","58","Departamento",-39.4807942918938,-70.4335593332799],
  ["Departamento Collón Curá","Collón Curá","58028","58","Departamento",-40.0529195538789,-70.2813499391274],
  ["Partido de Carlos Tejedor","Carlos Tejedor","06154","06","Partido",-35.379488920773,-62.4295611893429],
  ["Partido de Arrecifes","Arrecifes","06077","06","Partido",-34.0113151746224,-60.0627625274553],
  ["Partido de Capitán Sarmiento","Capitán Sarmiento","06140","06","Partido",-34.1497065018665,-59.8548037960898],
  ["Partido de Salto","Salto","06714","06","Partido",-34.2708350525697,-60.305182566345],
  ["Departamento Gualeguay","Gualeguay","30049","30","Departamento",-33.1199026931696,-59.6016234890441],
  ["Departamento Federación","Federación","30028","30","Departamento",-30.7348931499453,-58.1591541174073],
  ["Departamento Feliciano","Feliciano","30042","30","Departamento",-30.4139444642315,-58.7287958918597],
  ["Partido de 9 de Julio","9 de Julio","06588","06","Partido",-35.481190578256,-60.9751157295027],
  ["Partido de Trenque Lauquen","Trenque Lauquen","06826","06","Partido",-36.0564352739976,-62.6346332497416],
  ["Partido de Carlos Casares","Carlos Casares","06147","06","Partido",-35.7496551260772,-61.3737522686863],
  ["Partido de Olavarría","Olavarría","06595","06","Partido",-36.8567012129546,-60.6707349373354],
  ["Partido de Esteban Echeverría","Esteban Echeverría","06260","06","Partido",-34.8312099703342,-58.476969025414],
  ["Partido de General Viamonte","General Viamonte","06385","06","Partido",-34.997569924782,-61.0501968347291],
  ["Partido de Malvinas Argentinas","Malvinas Argentinas","06515","06","Partido",-34.4873038284663,-58.7121329971982],
  ["Partido de Lincoln","Lincoln","06469","06","Partido",-35.070384883326,-61.6827618200122],
  ["Partido de Tapalqué","Tapalqué","06798","06","Partido",-36.3471383108251,-60.1308804386321],
  ["Departamento Toay","Toay","42140","42","Departamento",-36.6621621527055,-64.6922110146556],
  ["Departamento Monte Caseros","Monte Caseros","18112","18","Departamento",-30.2289552221138,-57.8702855877153],
  ["Partido de Bragado","Bragado","06112","06","Partido",-35.0610928531071,-60.6042295511118],
  ["Partido de José M. Ezeiza","José M. Ezeiza","06270","06","Partido",-34.8758213531443,-58.5648395364287],
  ["Departamento Curacó","Curacó","42042","42","Departamento",-38.1797375458882,-66.3301334719636],
  ["Departamento Limay Mahuida","Limay Mahuida","42091","42","Departamento",-37.2419021199786,-66.555232691641],
  ["Departamento Puelén","Puelén","42112","42","Departamento",-37.4341807808756,-67.6049641366153],
  ["Partido de Florencio Varela","Florencio Varela","06274","06","Partido",-34.8778729879112,-58.2586377649204],
  ["Departamento Silípica","Silípica","86189","86","Departamento",-28.1888486587603,-64.2732683808708],
  ["Departamento 25de Mayo","25 de Mayo","54119","54","Departamento",-27.3786143623767,-54.634090486794],
  ["Partido de San Vicente","San Vicente","06778","06","Partido",-35.0704596398936,-58.4319219645129],
  ["Partido de Daireaux","Daireaux","06231","06","Partido",-36.6405459243249,-61.891417127905],
  ["Departamento 9 de Julio","9 de Julio","70063","70","Departamento",-31.6458046846082,-68.3890526964703],
  ["Departamento Rawson","Rawson","70077","70","Departamento",-31.6865858135558,-68.4675631318926],
  ["Partido de Ensenada","Ensenada","06245","06","Partido",-34.8422541242657,-57.9789322377767],
  ["Partido de Laprida","Laprida","06448","06","Partido",-37.5155525089772,-60.7680626719213],
  ["Partido de San Isidro","San Isidro","06756","06","Partido",-34.4869499670191,-58.5372648522523],
  ["Partido de Benito Juárez","Benito Juárez","06084","06","Partido",-37.585278315595,-59.8883008698795],
  ["Departamento San Antonio","San Antonio","38056","38","Departamento",-24.3467258804414,-65.4468528811404],
  ["Departamento Libertador General San Martín","Libertador General San Martín","22084","22","Departamento",-26.3785169756021,-59.4878778128786],
  ["Departamento Gastre","Gastre","26049","26","Departamento",-42.7490685142491,-68.802322331286],
  ["Partido de San Fernando","San Fernando","06749","06","Partido",-34.1512700249506,-58.5459540333809],
  ["Partido de Zárate","Zárate","06882","06","Partido",-33.9971401820257,-59.1284709610169],
  ["Departamento Salavina","Salavina","86168","86","Departamento",-28.9187435892712,-63.3035949540839],
  ["Departamento Pellegrini","Pellegrini","86133","86","Departamento",-26.2203346046951,-64.0912083069938],
  ["Departamento Avellaneda","Avellaneda","86028","86","Departamento",-28.5553626652401,-63.2037665884943],
  ["Departamento Bermejo","Bermejo","22014","22","Departamento",-26.958636224259,-58.7093649014335],
  ["Departamento Junín","Junín","74049","74","Departamento",-32.216548125306,-65.3939560584901],
  ["Departamento San Martín","San Martín","50098","50","Departamento",-32.9088785853185,-68.2844229443887],
  ["Departamento Zapala","Zapala","58112","58","Departamento",-38.922044155846,-69.8222074301959],
  ["Departamento Colón","Colón","14021","14","Departamento",-31.1440502226475,-64.1528709889175],
  ["Departamento Caseros","Caseros","82014","82","Departamento",-33.2214972343879,-61.5310164822665],
  ["Departamento Rosario","Rosario","82084","82","Departamento",-33.1278557358532,-60.7108416659256],
  ["Departamento San Lorenzo","San Lorenzo","82119","82","Departamento",-32.9423146043516,-60.9615014674026],
  ["Departamento Iriondo","Iriondo","82056","82","Departamento",-32.7060836088838,-61.2733877091661],
  ["Departamento Belgrano","Belgrano","82007","82","Departamento",-32.6103027395973,-61.7042951949086],
  ["Departamento San Jerónimo","San Jerónimo","82105","82","Departamento",-32.1537713586804,-61.0481265781191],
  ["Departamento Mitre","Mitre","86112","86","Departamento",-29.6150659886474,-62.7386805205781],
  ["Departamento Santa Victoria","Santa Victoria","66161","66","Departamento",-22.3958266942337,-64.8956351260047],
  ["Departamento General José de San Martín","General José de San Martín","66056","66","Departamento",-22.7169492299382,-63.6627437658428],
  ["Departamento Pilcomayo","Pilcomayo","34049","34","Departamento",-25.3700377167627,-58.062606265553],
  ["Departamento Río Primero","Río Primero","14105","14","Departamento",-31.0327992067991,-63.4385673505455],
  ["Departamento Tinogasta","Tinogasta","10105","10","Departamento",-27.5405127310562,-67.9292408147481],
  ["Departamento Marcos Juárez","Marcos Juárez","14063","14","Departamento",-33.030846572143,-62.2767719720096],
  ["Departamento Calamuchita","Calamuchita","14007","14","Departamento",-32.2027119466219,-64.6167170389735],
  ["Departamento Chacabuco","Chacabuco","74028","74","Departamento",-32.7269672116015,-65.1982374778981],
  ["Departamento Juan Martín de Pueyrredón","Juan Martín de Pueyrredón","74056","74","Departamento",-33.9008795169272,-66.5025775641531],
  ["Departamento General Pedernera","General Pedernera","74035","74","Departamento",-33.8905514573194,-65.56285207424],
  ["Partido de Patagones","Patagones","06602","06","Partido",-40.1973260070881,-62.8529094080666],
  ["Departamento Libertador General San Martín","Libertador General San Martín","74063","74","Departamento",-32.5784192360116,-65.7095887724917],
  ["Departamento Coronel Pringles","Coronel Pringles","74021","74","Departamento",-33.1068820542746,-65.900790202998],
  ["Comuna 1","Comuna 1","02007","02","Comuna",-34.6064218855511,-58.3715396530269],
  ["Comuna 4","Comuna 4","02028","02","Comuna",-34.6420794257822,-58.3874550689885],
  ["Comuna 5","Comuna 5","02035","02","Comuna",-34.617369923785,-58.4205721902857],
  ["Departamento Caleu Caleu","Caleu Caleu","42014","42","Departamento",-38.6755832575061,-63.8968179856269],
  ["Departamento Jáchal","Jáchal","70056","70","Departamento",-30.3550759493245,-68.4412683481467],
  ["Departamento Quebrachos","Quebrachos","86140","86","Departamento",-29.382302416388,-63.3535127711283],
  ["Departamento Mburucuyá","Mburucuyá","18098","18","Departamento",-28.0163816801467,-58.1855624499057],
  ["Departamento Empedrado","Empedrado","18042","18","Departamento",-27.8961218833917,-58.6658439667722],
  ["Departamento Ituzaingó","Ituzaingó","18084","18","Departamento",-27.9114257175706,-56.7904763823004],
  ["Departamento San Cosme","San Cosme","18133","18","Departamento",-27.3823055047941,-58.5174860021794],
  ["Departamento Itatí","Itatí","18077","18","Departamento",-27.3460562357383,-58.0713754415461],
  ["Comuna 12","Comuna 12","02084","02","Comuna",-34.5662276065396,-58.490428041078],
  ["Departamento San Javier","San Javier","54105","54","Departamento",-27.7771031457714,-55.1674595934642],
  ["Departamento Apóstoles","Apóstoles","54007","54","Departamento",-27.8888038850636,-55.6782740306512],
  ["Departamento Eldorado","Eldorado","54042","54","Departamento",-26.3138449973517,-54.4407363386818],
  ["Departamento San Pedro","San Pedro","54112","54","Departamento",-26.6299609405552,-53.9629779665021],
  ["Departamento Montecarlo","Montecarlo","54084","54","Departamento",-26.6579081276292,-54.5631774073677],
  ["Partido de Chascomús","Chascomús","06217","06","Partido",-35.6187689428966,-57.9043202817554],
  ["Comuna 15","Comuna 15","02105","02","Comuna",-34.5918836701565,-58.4627740218828],
  ["Departamento San Martín","San Martín","86175","86","Departamento",-28.1877612837658,-63.854114579231],
  ["Departamento Jiménez","Jiménez","86091","86","Departamento",-26.899591169452,-64.2725159118858],
  ["Partido de Baradero","Baradero","06070","06","Partido",-33.9321914567436,-59.4929504876902],
  ["Departamento Humahuaca","Humahuaca","38028","38","Departamento",-23.0821382910047,-65.4089124214828],
  ["Departamento Yaví","Yaví","38112","38","Departamento",-22.2906705371725,-65.5669616842196],
  ["Departamento Santa Catalina","Santa Catalina","38077","38","Departamento",-22.137931595162,-66.227664877192],
  ["Departamento San Pedro","San Pedro","38063","38","Departamento",-24.2985497355434,-64.8110140944895],
  ["Departamento Valle Grande","Valle Grande","38105","38","Departamento",-23.4670612447247,-65.0119194137172],
  ["Departamento Patiño","Patiño","34035","34","Departamento",-24.8750609917942,-59.9585024741836],
  ["Departamento Bermejo","Bermejo","34007","34","Departamento",-24.0255563345755,-61.2828019983788],
  ["Departamento Susques","Susques","38084","38","Departamento",-23.5204314374652,-66.6617993267455],
  ["Departamento Iruya","Iruya","66070","66","Departamento",-22.8148374145959,-64.9202186004952],
  ["Departamento Matacos","Matacos","34028","34","Departamento",-23.854855944809,-62.076891256733],
  ["Departamento Los Andes","Los Andes","66105","66","Departamento",-24.6424364614968,-67.34403275869],
  ["Departamento Orán","Orán","66126","66","Departamento",-23.4987690402927,-64.1510163822065],
  ["Departamento Tilcara","Tilcara","38094","38","Departamento",-23.560543852464,-65.3197513527091],
  ["Departamento Palpalá","Palpalá","38042","38","Departamento",-24.1949225444459,-65.1264498289923],
  ["Departamento Cochinoca","Cochinoca","38007","38","Departamento",-22.9392350234639,-65.9346878202021],
  ["Departamento Tumbaya","Tumbaya","38098","38","Departamento",-23.7434725633393,-65.696096204681],
  ["Departamento Dr. Manuel Belgrano","Dr. Manuel Belgrano","38021","38","Departamento",-24.0893413107767,-65.4484768876505],
  ["Departamento Santa Bárbara","Santa Bárbara","38070","38","Departamento",-24.0075465739997,-64.4023110880998],
  ["Departamento Rinconada","Rinconada","38049","38","Departamento",-22.6216157957901,-66.5415733150047],
  ["Departamento La Poma","La Poma","66091","66","Departamento",-24.1468804221181,-66.2073097573146],
  ["Departamento Chicligasta","Chicligasta","90021","90","Departamento",-27.2695777554986,-65.8110121945484],
  ["Departamento Monteros","Monteros","90070","90","Departamento",-27.1106075164054,-65.6431429705926],
  ["Departamento Leales","Leales","90056","90","Departamento",-27.1918024636989,-65.0850078123385],
  ["Departamento Famaillá","Famaillá","90028","90","Departamento",-26.9759879123642,-65.4789798424484],
  ["Departamento Capital","Capital","90084","90","Departamento",-26.832724441173,-65.2174963397207],
  ["Departamento Cruz Alta","Cruz Alta","90014","90","Departamento",-26.9182437174427,-64.9757343718485],
  ["Departamento Trancas","Trancas","90112","90","Departamento",-26.3432601177699,-65.4054839941384],
  ["Departamento Tafí del Valle","Tafí del Valle","90098","90","Departamento",-26.5914036518985,-65.8894957616981],
  ["Departamento San Martín","San Martín","82126","82","Departamento",-32.0125797507259,-61.8082508211602],
  ["Departamento San Luis del Palmar","San Luis del Palmar","18140","18","Departamento",-27.6020473964888,-58.2685422687085],
  ["Departamento Berón de Astrada","Berón de Astrada","18014","18","Departamento",-27.4779720010057,-57.6113792118725],
  ["Departamento Castellanos","Castellanos","82021","82","Departamento",-31.2314149716439,-61.6569626868615],
  ["Departamento San Justo","San Justo","82112","82","Departamento",-30.5304248150144,-60.4886940672765],
  ["Departamento San Cristóbal","San Cristóbal","82091","82","Departamento",-30.2283191431559,-61.360015159641],
  ["Departamento San Javier","San Javier","82098","82","Departamento",-30.1041461066388,-59.8980704738644],
  ["Departamento General Obligado","General Obligado","82049","82","Departamento",-28.6719704542176,-59.5266516978974],
  ["Departamento Chimbas","Chimbas","70042","70","Departamento",-31.4874196948621,-68.5239289662613],
  ["Departamento San Martín","San Martín","70091","70","Departamento",-31.5285412012606,-68.2072931248825],
  ["Departamento Biedma","Biedma","26007","26","Departamento",-42.4436350204267,-64.9332260287713],
  ["Partido de Florentino Ameghino","Florentino Ameghino","06277","06","Partido",-34.8738967496734,-62.4013534701346],
  ["Departamento Florentino Ameghino","Florentino Ameghino","26028","26","Departamento",-44.4232685527937,-66.1300665443193],
  ["Departamento La Cocha","La Cocha","90049","90","Departamento",-27.793699696551,-65.5981413742508],
  ["Departamento Juan Bautista Alberdi","Juan Bautista Alberdi","90042","90","Departamento",-27.6058945987109,-65.7832035039246],
  ["Departamento Río Chico","Río Chico","90077","90","Departamento",-27.450131903938,-65.7517295073354],
  ["Departamento Simoca","Simoca","90091","90","Departamento",-27.424163373399,-65.2918660955326],
  ["Departamento General López","General López","82042","82","Departamento",-33.9251483443292,-61.9449986852751],
  ["Departamento Candelaria","Candelaria","54021","54","Departamento",-27.4608502028348,-55.5826897694998],
  ["Departamento Cainguás","Cainguás","54014","54","Departamento",-27.1478299707848,-54.802339249309],
  ["Departamento Libertador General San Martín","Libertador General San Martín","54077","54","Departamento",-26.8931448853066,-54.9233629496583],
  ["Departamento General Manuel Belgrano","General Manuel Belgrano","54049","54","Departamento",-25.9786262379125,-53.9636582644351],
  ["Departamento Guaraní","Guaraní","54056","54","Departamento",-27.0262341090705,-54.2693679741111],
  ["Departamento Rivadavia","Rivadavia","70084","70","Departamento",-31.5542325394479,-68.6416232535812],
  ["Departamento Santa Lucía","Santa Lucía","70098","70","Departamento",-31.5327173670967,-68.4634116809574],
  ["Departamento Pocito","Pocito","70070","70","Departamento",-31.7459555808161,-68.5842081096793],
  ["Departamento Sarmiento","Sarmiento","70105","70","Departamento",-32.073542322508,-68.691135621109],
  ["Departamento Capital","Capital","70028","70","Departamento",-31.5330748483572,-68.5342856277406],
  ["Departamento Chapaleufú","Chapaleufú","42056","42","Departamento",-35.2272428701704,-63.6609121074931],
  ["Departamento Maracó","Maracó","42105","42","Departamento",-35.6796177582431,-63.6624891520267],
  ["Departamento Concepción","Concepción","18028","18","Departamento",-28.4083953496766,-58.031384641798],
  ["Departamento Leandro N. Alem","Leandro N. Alem","54070","54","Departamento",-27.6306652578033,-55.3880677535388]
]

departments_list.each do |complete_name, name, national_id, province_national_id, category, lat, lon|
  Department.find_or_create_by(complete_name: complete_name, name: name, national_id: national_id, province: Province.where(national_id: province_national_id).first, category: category, lat: lat, lon: lon)
end

localities_list = [
  ["06084","Benito Juárez","06084020","Localidad simple",-37.6766410210104,-59.8057677109444],
  ["06084","López","06084030","Localidad simple",-37.5545120854221,-59.6278461536299],
  ["06084","Tedín Uriburu","06084040","Localidad simple",-37.3683686253208,-59.7630391604187],
  ["06084","Villa Cacique","06084050","Localidad simple",-37.6704778893557,-59.4003533386514],
  ["06091","Berazategui","06091010","Componente de localidad compuesta",-34.7633439435624,-58.2078083914443],
  ["06098","Berisso","06098010","Componente de localidad compuesta",-34.8764141983789,-57.8863953320288],
  ["06105","Hale","06105010","Localidad simple",-36.0010429767568,-60.8534495072374],
  ["06105","Juan F. Ibarra","06105020","Localidad simple",-36.3498770527922,-61.2552591224517],
  ["06105","Paula","06105040","Localidad simple",-36.5053183545527,-61.0243287245345],
  ["06105","Pirovano","06105050","Localidad simple",-36.5109170215402,-61.5545516558692],
  ["06105","San Carlos de Bolívar","06105060","Localidad simple",-36.2295602208798,-61.1131898679982],
  ["06105","Urdampilleta","06105070","Localidad simple",-36.4329292363695,-61.419116019242],
  ["06105","Villa Lynch Pueyrredón","06105080","Localidad simple",-36.6025793254646,-61.3618625494724],
  ["06112","Asamblea","06112005","Localidad simple",-35.2267581272748,-60.4168952837295],
  ["06112","Bragado","06112010","Localidad simple",-35.1189422997629,-60.4879147568209],
  ["06112","Comodoro Py","06112020","Localidad simple",-35.3233100374631,-60.5217314911689],
  ["06112","General O'Brien","06112030","Localidad simple",-34.9067979091956,-60.7597838238054],
  ["06112","Irala","06112040","Localidad simple",-34.7718230311122,-60.6916912010277],
  ["06112","La Limpia","06112050","Localidad simple",-35.0797272650156,-60.5928546665185],
  ["06112","Juan F. Salaberry","06112060","Localidad simple",-35.0615246745825,-60.7060741424473],
  ["06112","Mechita","06112070","Componente de localidad compuesta",-35.0699378566803,-60.4084937925362],
  ["06112","Olascoaga","06112080","Localidad simple",-35.2375277927366,-60.6115341696178],
  ["06112","Warnes","06112090","Localidad simple",-34.9098734445056,-60.5381681629003],
  ["06119","Altamirano","06119010","Localidad simple",-35.3615828022139,-58.1504868159157],
  ["06119","Barrio El Mirador","06119015","Localidad simple",-35.3145370547125,-58.0484420796345],
  ["06119","Barrio Las Golondrinas","06119020","Localidad simple",-35.0335777783555,-58.1935382681817],
  ["06119","Barrio Los Bosquecitos","06119030","Localidad simple",-35.1050389949725,-58.1835007859607],
  ["06119","Barrio Parque Las Acacias","06119040","Localidad simple",-35.1030329461442,-58.2730405375653],
  ["06119","Campos de Roca","06119045","Localidad simple",-35.1149772603157,-58.0953896541907],
  ["06119","Coronel Brandsen","06119050","Localidad simple",-35.1690983002919,-58.2373529446643],
  ["06119","Club de Campo Las Malvinas","06119055","Localidad simple",-35.2139978115731,-58.2433030920635],
  ["06119","Gómez","06119060","Localidad simple",-35.0693655332834,-58.1656899882305],
  ["06119","Jeppener","06119070","Localidad simple",-35.2802043920968,-58.1996649431989],
  ["06119","Oliden","06119080","Localidad simple",-35.1842584334678,-57.9479623248001],
  ["06119","Posada de los Lagos","06119085","Localidad simple",-35.1499383981993,-58.0504528667351],
  ["06119","Samborombón","06119090","Localidad simple",-35.2206242719966,-58.2805297949826],
  ["06126","Los Cardales","06126010","Componente de localidad compuesta",-34.3160243688815,-58.9784574815339],
  ["06126","Barrio Los Pioneros (Barrio Tavella)","06126020","Localidad simple",-34.2530406367633,-58.9584400368589],
  ["06126","Campana","06126030","Localidad simple",-34.1639618118269,-58.9588741035355],
  ["06126","Chacras del Río Luján","06126035","Localidad simple",-34.2934153226239,-58.921199044246],
  ["06126","Río Luján","06126040","Localidad simple",-34.2816770641806,-58.8911906524052],
  ["06134","Alejandro Petión","06134010","Localidad simple",-34.9793768508134,-58.6749430768989],
  ["06134","Barrio El Taladro","06134020","Localidad simple",-35.0742486164225,-58.8632420603475],
  ["06134","Cañuelas","06134030","Localidad simple",-35.0527140350539,-58.7583856965375],
  ["06134","Gobernador Udaondo","06134040","Localidad simple",-35.3003271130454,-58.5943053657455],
  ["06134","Máximo Paz","06134050","Componente de localidad compuesta",-34.9405321574521,-58.6160962899907],
  ["06134","Santa Rosa","06134060","Localidad simple",-34.9611839371811,-58.7308918275978],
  ["06134","Uribelarrea","06134070","Localidad simple",-35.1227364407356,-58.8904871463421],
  ["06134","Vicente Casares","06134080","Localidad simple",-34.9653526702416,-58.6504979594296],
  ["06140","Capitán Sarmiento","06140010","Localidad simple",-34.1723674255219,-59.789349139091],
  ["06140","La Luisa","06140020","Localidad simple",-34.1285572110784,-59.9240058312679],
  ["06147","Bellocq","06147010","Localidad simple",-35.9189705554631,-61.5312630222769],
  ["06147","Cadret","06147020","Localidad simple",-35.7727531397053,-61.3353879836967],
  ["06147","Carlos Casares","06147030","Localidad simple",-35.623543502046,-61.3653159121918],
  ["06147","Colonia Mauricio","06147040","Localidad simple",-35.5249595511909,-61.4378670824782],
  ["06147","Hortensia","06147050","Localidad simple",-35.9277092575349,-61.262290153739],
  ["06147","La Sofía","06147060","Localidad simple",-35.7003907357414,-61.1702865161871],
  ["06147","Mauricio Hirsch","06147070","Localidad simple",-35.583017649873,-61.5244457086778],
  ["06147","Moctezuma","06147080","Localidad simple",-35.4774725641963,-61.4930734927676],
  ["06147","Ordoqui","06147090","Localidad simple",-35.8831262095535,-61.1594280439031],
  ["06147","Santo Tomás","06147095","Localidad simple",-35.6740915009624,-61.5066664301674],
  ["06147","Smith","06147100","Localidad simple",-35.4946290260766,-61.5937811081594],
  ["06154","Carlos Tejedor","06154010","Localidad simple",-35.3925733302196,-62.4193023144118],
  ["06154","Colonia Seré","06154020","Localidad simple",-35.4388157700903,-62.7252382146864],
  ["06154","Curarú","06154030","Localidad simple",-35.6403503028113,-62.1924372294866],
  ["06154","Timote","06154040","Localidad simple",-35.3477615165229,-62.2246532791856],
  ["06154","Tres Algarrobos","06154050","Localidad simple",-35.1979815144911,-62.7730814064669],
  ["06161","Carmen de Areco","06161010","Localidad simple",-34.3776987251735,-59.8229019801033],
  ["06161","Pueblo Gouin","06161020","Localidad simple",-34.4951191416005,-59.8029737383366],
  ["06161","Tres Sargentos","06161030","Localidad simple",-34.4664778301466,-60.0008697422008],
  ["06168","Castelli","06168010","Localidad simple",-36.091694119436,-57.8071801619355],
  ["06168","Centro Guerrero","06168020","Localidad simple",-36.0570621940227,-57.8235422591575],
  ["06168","Cerro de la Gloria","06168030","Localidad simple",-35.976053059995,-57.4487354447874],
  ["06175","Colón","06175010","Localidad simple",-33.8978633606345,-61.099560506382],
  ["06175","Villa Manuel Pomar","06175020","Componente de localidad compuesta",-33.9147838019682,-60.9438081845998],
  ["06175","Pearson","06175030","Localidad simple",-33.6518963027432,-60.8922239880462],
  ["06175","Sarasa","06175040","Localidad simple",-34.0523353092343,-61.2019040914738],
  ["06182","Bajo Hondo","06182010","Localidad simple",-38.7648159927502,-61.9184051093309],
  ["06182","Balneario Pehuen Co","06182020","Localidad simple",-38.9961963948629,-61.5471990087107],
  ["06182","Pago Chico","06182025","Localidad simple",-38.7839402799391,-62.1195194756714],
  ["06182","Punta Alta","06182030","Localidad simple",-38.8813527346955,-62.0749536088688],
  ["06182","Villa General Arias","06182050","Localidad simple",-38.8069001411051,-62.09498539538],
  ["06189","Aparicio","06189010","Localidad simple",-38.6204949120776,-60.8809603426407],
  ["06189","Marisol","06189020","Localidad simple",-38.9224906889726,-60.5329774471942],
  ["06189","Coronel Dorrego","06189030","Localidad simple",-38.7166239148323,-61.2884948879698],
  ["06189","El Perdido","06189040","Localidad simple",-38.6757752787603,-61.0884421797928],
  ["06189","Faro","06189050","Localidad simple",-38.7966781095909,-61.0688772134763],
  ["06189","Irene","06189060","Localidad simple",-38.5543426342658,-60.6954938748393],
  ["06189","Oriente","06189070","Localidad simple",-38.7388491145692,-60.6092238150828],
  ["06189","Paraje La Ruta","06189075","Localidad simple",-38.6534164106777,-60.8608557685895],
  ["06189","San Román","06189080","Localidad simple",-38.7415550885108,-61.5377200112301],
  ["06196","Coronel Pringles","06196010","Localidad simple",-37.9865210556901,-61.3540715661068],
  ["06196","El Divisorio","06196020","Localidad simple",-38.3235636030787,-61.4450578127822],
  ["06196","El Pensamiento","06196030","Localidad simple",-38.2154094275446,-61.3145847771451],
  ["06196","Indio Rico","06196040","Localidad simple",-38.3293770967784,-60.8866340266383],
  ["06196","Lartigau","06196050","Localidad simple",-38.44591903663,-61.566096860456],
  ["06203","Cascada","06203010","Localidad simple",-37.2899615825436,-62.2971682457111],
  ["06203","Coronel Suárez","06203020","Localidad simple",-37.4596224938743,-61.9317530113989],
  ["06203","Curamalal","06203030","Localidad simple",-37.4843018699441,-62.10361959864],
  ["06203","D'Orbigny","06203040","Localidad simple",-37.6772293087783,-61.7052608546557],
  ["06203","Huanguelén","06203050","Localidad simple",-37.0622288209544,-61.9297529087938],
  ["06203","Pasman","06203060","Localidad simple",-37.2234351404125,-62.1602259170472],
  ["06203","San José","06203070","Localidad simple",-37.5077480260109,-61.9211473085303],
  ["06203","Santa María","06203080","Localidad simple",-37.5565856774998,-61.872634363442],
  ["06203","Santa Trinidad","06203090","Localidad simple",-37.4891036510029,-61.9252761219778],
  ["06203","Villa La Arcadia","06203100","Componente de localidad compuesta",-38.1345025284944,-61.7885553500206],
  ["06210","Castilla","06210010","Localidad simple",-34.6131247014799,-59.9005194580559],
  ["06210","Chacabuco","06210020","Localidad simple",-34.6429843999409,-60.4701843504346],
  ["06210","Los Angeles","06210030","Localidad simple",-34.4575064000002,-60.1801845132051],
  ["06210","O'Higgins","06210040","Localidad simple",-34.5854707868254,-60.6986325840688],
  ["06210","Rawson","06210050","Localidad simple",-34.6086374337309,-60.0677106761006],
  ["06217","Barrio Lomas Altas","06217003","Localidad simple",-35.5739889229165,-58.0680436475186],
  ["06217","Chascomús","06217010","Localidad simple",-35.5770827047567,-58.0084847937359],
  ["06217","Laguna Vitel","06217015","Localidad simple",-35.5404169288645,-58.1349194201314],
  ["06217","Manuel J. Cobo","06217020","Localidad simple",-35.8748248734085,-57.8964226760932],
  ["06217","Villa Parque Girado","06217030","Localidad simple",-35.6282696386352,-58.0145524400059],
  ["06224","Benitez","06224005","Localidad simple",-34.9660329017518,-60.1236385563996],
  ["06224","Chivilcoy","06224010","Localidad simple",-34.8980163772726,-60.0188841030321],
  ["06224","Emilio Ayarza","06224020","Localidad simple",-34.746060108407,-60.0392314192743],
  ["06224","Gorostiaga","06224030","Localidad simple",-34.839127302807,-59.8646671984292],
  ["06224","La Rica","06224040","Localidad simple",-34.9739189538858,-59.8639302070489],
  ["06224","Moquehuá","06224050","Localidad simple",-35.0926582854313,-59.7745302971612],
  ["06224","Ramón Biaus","06224060","Localidad simple",-35.0858455213162,-59.9236682591743],
  ["06224","San Sebastián","06224070","Localidad simple",-34.9443783815262,-59.7018597369347],
  ["06231","Andant","06231010","Localidad simple",-36.5640579804658,-62.1324009778233],
  ["06231","Arboledas","06231020","Localidad simple",-36.8827708539235,-61.4878179060517],
  ["06231","Daireaux","06231030","Localidad simple",-36.6001749213746,-61.7450132654369],
  ["06231","La Larga","06231040","Localidad simple",-36.6749256386405,-61.9291952273289],
  ["06231","Salazar","06231060","Localidad simple",-36.307117163487,-62.2003365899],
  ["06238","Dolores","06238010","Localidad simple",-36.3161215739926,-57.6752657333964],
  ["06238","Sevigne","06238020","Localidad simple",-36.2067284269712,-57.7413707296745],
  ["06245","Ensenada","06245010","Componente de localidad compuesta",-34.859087650169,-57.9132063028971],
  ["06252","Escobar","06252010","Componente de localidad compuesta",-34.3478151482937,-58.792041970497],
  ["06260","Esteban Echeverría","06260010","Componente de localidad compuesta",-34.8182320587028,-58.4653924015445],
  ["06266","Arroyo de la Cruz","06266010","Localidad simple",-34.3363786908945,-59.1094149717708],
  ["06266","Capilla del Señor","06266020","Localidad simple",-34.2912108668035,-59.1015232724441],
  ["06266","Diego Gaynor","06266030","Localidad simple",-34.288973975279,-59.222781222713],
  ["06266","Los Cardales","06266040","Componente de localidad compuesta",-34.3300736993853,-58.9885651588167],
  ["06266","Parada Orlando","06266050","Localidad simple",-34.3273003551547,-59.0759905460337],
  ["06266","Parada Robles - Pavón","06266060","Componente de localidad compuesta",-34.3751967438675,-59.1237945023542],
  ["06270","Ezeiza","06270010","Componente de localidad compuesta",-34.8499164466297,-58.522884786315],
  ["06274","Florencio Varela","06274010","Componente de localidad compuesta",-34.8080028544593,-58.2762820744731],
  ["06277","Blaquier","06277010","Localidad simple",-34.6356616332747,-62.4786821321875],
  ["06277","Florentino Ameghino","06277020","Localidad simple",-34.846677699169,-62.4671575805383],
  ["06277","Porvenir","06277030","Localidad simple",-34.9522292183733,-62.2174229886621],
  ["06280","Centinela del Mar","06280005","Localidad simple",-38.4348806367321,-58.216863731472],
  ["06280","Comandante Nicanor Otamendi","06280010","Localidad simple",-38.1119335118514,-57.8415353121543],
  ["06280","Mar del Sur","06280020","Localidad simple",-38.3446881533109,-57.9920393065731],
  ["06280","Mechongué","06280030","Localidad simple",-38.1486545138318,-58.2230121065801],
  ["06280","Miramar","06280040","Componente de localidad compuesta",-38.2707429318083,-57.8404714577536],
  ["06287","General Alvear","06287010","Localidad simple",-36.0229384341366,-60.0147935726886],
  ["06294","Arribeños","06294010","Localidad simple",-34.2101542565966,-61.3548577979495],
  ["06294","Ascensión","06294020","Localidad simple",-34.2368758979793,-61.103613881133],
  ["06294","Estación Arenales","06294030","Localidad simple",-34.2698455922697,-61.2926718130401],
  ["06294","Ferré","06294040","Localidad simple",-34.1250383813873,-61.132654886464],
  ["06294","General Arenales","06294050","Localidad simple",-34.3044679711076,-61.3056277788216],
  ["06294","La Angelita","06294060","Localidad simple",-34.2608740726731,-60.9685988224111],
  ["06294","La Trinidad","06294070","Localidad simple",-34.1068549430168,-61.1317020714356],
  ["06301","General Belgrano","06301010","Localidad simple",-35.7694577358026,-58.4944615102033],
  ["06301","Gorchs","06301020","Localidad simple",-35.6733729629116,-58.9582999568816],
  ["06308","General Guido","06308010","Localidad simple",-36.6431651777016,-57.790501903704],
  ["06308","Labardén","06308020","Localidad simple",-36.9489668508722,-58.1035671819428],
  ["06315","General Juan Madariaga","06315010","Localidad simple",-36.9956399453583,-57.1364809577407],
  ["06322","General La Madrid","06322010","Localidad simple",-37.2503992475804,-61.2595794125711],
  ["06322","La Colina","06322020","Localidad simple",-37.3607690235166,-61.5348487870647],
  ["06322","Las Martinetas","06322030","Localidad simple",-37.1980813542863,-61.1220424031556],
  ["06322","Líbano","06322040","Localidad simple",-37.53362138441,-61.2865750087495],
  ["06322","Pontaut","06322050","Localidad simple",-37.7317699033739,-61.3230957170244],
  ["06329","General Hornos","06329010","Localidad simple",-34.8937763345299,-58.9172215319327],
  ["06329","General Las Heras","06329020","Localidad simple",-34.9267739074255,-58.9453407851291],
  ["06329","La Choza","06329030","Localidad simple",-34.7829908276155,-59.1095647693247],
  ["06329","Plomer","06329050","Localidad simple",-34.7941193667757,-59.0279756935744],
  ["06329","Villars","06329060","Localidad simple",-34.8300241949658,-58.9422589402025],
  ["06336","General Lavalle","06336020","Localidad simple",-36.4080851872455,-56.9433553335053],
  ["06336","Pavón","06336030","Localidad simple",-36.7089537726649,-56.7598433617574],
  ["06343","Barrio Río Salado","06343010","Localidad simple",-35.6936377582584,-58.447313612508],
  ["06343","Loma Verde","06343020","Localidad simple",-35.2747490125694,-58.4041701894263],
  ["06343","Ranchos","06343030","Localidad simple",-35.5173520233652,-58.3184247148652],
  ["06343","Villanueva","06343040","Localidad simple",-35.6776271050908,-58.4350923167562],
  ["06351","Colonia San Ricardo","06351010","Localidad simple",-34.4162137301573,-61.9280141749282],
  ["06351","General Pinto","06351020","Localidad simple",-34.764155990724,-61.8900674920122],
  ["06351","Germania","06351030","Localidad simple",-34.5761118332769,-62.0518306894073],
  ["06351","Gunther","06351035","Localidad simple",-34.5994995308259,-61.9164989081536],
  ["06351","Villa Francia","06351040","Localidad simple",-34.7913160212074,-62.2011090686366],
  ["06351","Villa Roth","06351050","Localidad simple",-34.5798302278832,-62.1710489234118],
  ["06357","Barrio El Boquerón","06357020","Localidad simple",-38.0297229162982,-57.7995485049706],
  ["06357","Barrio La Gloria","06357050","Localidad simple",-37.9068268303117,-57.7858860640391],
  ["06357","Barrio Santa Paula","06357060","Localidad simple",-37.9317157840639,-57.683162032898],
  ["06357","Batán","06357070","Localidad simple",-38.0086211557,-57.7085500402678],
  ["06357","Chapadmalal","06357080","Localidad simple",-38.1757779275595,-57.6513390003209],
  ["06357","El Marquesado","06357090","Componente de localidad compuesta",-38.2369312519788,-57.7634180779219],
  ["06357","Estación Chapadmalal","06357100","Localidad simple",-38.036727731373,-57.7129897398616],
  ["06357","Mar del Plata","06357110","Localidad simple",-37.9988640075371,-57.547532938743],
  ["06357","Sierra de los Padres","06357120","Localidad simple",-37.954166706805,-57.7715971022228],
  ["06364","General Rodríguez","06364030","Componente de localidad compuesta",-34.6079239021062,-58.950282039134],
  ["06371","General San Martín","06371010","Componente de localidad compuesta",-34.5696533775117,-58.5349543497109],
  ["06385","Baigorrita","06385010","Localidad simple",-34.7472686783062,-60.9889526585307],
  ["06385","La Delfina","06385020","Localidad simple",-34.9437720137007,-61.1588643543904],
  ["06385","Los Toldos","06385030","Localidad simple",-35.0010365651503,-61.0381497866181],
  ["06385","San Emilio","06385040","Localidad simple",-35.0319914044113,-60.8647685857183],
  ["06385","Zavalía","06385050","Localidad simple",-34.8949208760254,-61.0044538243488],
  ["06392","Banderaló","06392010","Localidad simple",-35.0124666610174,-63.3741563457185],
  ["06392","Cañada Seca","06392020","Localidad simple",-34.4155054560621,-62.9618553806295],
  ["06392","Coronel Charlone","06392030","Localidad simple",-34.672994561958,-63.3724454840571],
  ["06392","Emilio V. Bunge","06392040","Localidad simple",-34.7798328261907,-63.1960964862342],
  ["06392","General Villegas","06392050","Localidad simple",-35.0338419886306,-63.014663710753],
  ["06392","Massey","06392060","Localidad simple",-35.0490892294374,-63.1218876844045],
  ["06392","Pichincha","06392070","Localidad simple",-34.5804516676438,-62.3516395240412],
  ["06392","Piedritas","06392080","Localidad simple",-34.771104540922,-62.9846965760316],
  ["06392","Santa Eleodora","06392090","Localidad simple",-34.6921180067125,-62.6957932681386],
  ["06392","Santa Regina","06392100","Localidad simple",-34.548335663977,-63.1732728724567],
  ["06392","Villa Saboya","06392110","Localidad simple",-34.4607916334895,-62.649344456796],
  ["06392","Villa Sauze","06392120","Localidad simple",-35.2858298200472,-63.3682055476167],
  ["06399","Arroyo Venado","06399010","Localidad simple",-37.0864662845331,-62.5391482291111],
  ["06399","Casbas","06399020","Localidad simple",-36.7580953396186,-62.5017754084549],
  ["06399","Garré","06399030","Localidad simple",-36.5604378772819,-62.5981120377825],
  ["06399","Guaminí","06399040","Localidad simple",-37.0120881308673,-62.4166857296556],
  ["06399","Laguna Alsina","06399050","Localidad simple",-36.80905243808,-62.2451480754422],
  ["06406","Henderson","06406010","Localidad simple",-36.2994630370091,-61.7178401805261],
  ["06406","Herrera Vegas","06406020","Localidad simple",-36.0883254041476,-61.4112500767202],
  ["06408","Hurlingham","06408010","Componente de localidad compuesta",-34.5926049478957,-58.6334584554374],
  ["06410","Ituzaingó","06410010","Componente de localidad compuesta",-34.6625047224141,-58.6660777676772],
  ["06412","José C. Paz","06412010","Componente de localidad compuesta",-34.5193349747122,-58.7497681367601],
  ["06413","Agustín Roca","06413010","Localidad simple",-34.508084406003,-60.8648956546313],
  ["06413","Agustina","06413020","Localidad simple",-34.4607068571169,-61.067072329925],
  ["06413","Balneario Laguna de Gómez","06413030","Localidad simple",-34.6606435780718,-61.0183645929666],
  ["06413","Fortín Tiburcio","06413040","Localidad simple",-34.3467322372427,-61.1310781728463],
  ["06413","Junín","06413050","Localidad simple",-34.5838316271397,-60.9472651715326],
  ["06413","Paraje La Agraria","06413055","Localidad simple",-34.6564145153102,-60.8466681579607],
  ["06413","Laplacette","06413060","Localidad simple",-34.7245238530675,-61.1553171474145],
  ["06413","Saforcada","06413080","Localidad simple",-34.5752591285936,-61.0747308195452],
  ["06420","Las Toninas","06420010","Localidad simple",-36.4883976285615,-56.7004352579533],
  ["06420","Mar de Ajó - San Bernardo","06420020","Localidad simple",-36.7234307065769,-56.6771596535959],
  ["06420","San Clemente del Tuyú","06420030","Componente de localidad compuesta",-36.3532388310754,-56.723944139417],
  ["06420","Santa Teresita - Mar del Tuyú","06420040","Localidad simple",-36.577496173436,-56.6926713688296],
  ["06427","La Matanza","06427010","Componente de localidad compuesta",-34.6764437241804,-58.5603685341933],
  ["06434","Lanús","06434010","Componente de localidad compuesta",-34.706359523865,-58.3910857563038],
  ["06441","Country Club El Rodeo","06441010","Localidad simple",-35.0794688053886,-58.1393275732941],
  ["06441","Ignacio Correas","06441020","Localidad simple",-35.0345600341406,-57.8440249586726],
  ["06441","La Plata","06441030","Componente de localidad compuesta",-34.9220666561801,-57.9543916496992],
  ["06441","Lomas de Copello","06441040","Localidad simple",-34.9520385659845,-57.8409385980166],
  ["06441","Ruta Sol","06441050","Componente de localidad compuesta",-34.9437333541431,-58.1732652389706],
  ["06448","Laprida","06448010","Localidad simple",-37.5467976434903,-60.7970535965801],
  ["06448","Pueblo Nuevo","06448020","Localidad simple",-37.5227045258336,-60.7705546208497],
  ["06448","Pueblo San Jorge","06448030","Localidad simple",-37.2298626892886,-60.9621658450441],
  ["06455","Coronel Boerr","06455010","Localidad simple",-35.9414440334215,-59.0693547287839],
  ["06455","El Trigo","06455020","Localidad simple",-35.8815483511482,-59.4063369903389],
  ["06455","Las Flores","06455030","Localidad simple",-36.0154969145348,-59.1004659218434],
  ["06455","Pardo","06455040","Localidad simple",-36.2437580460508,-59.3662916338311],
  ["06462","Alberdi Viejo","06462010","Localidad simple",-34.4418003349,-61.8448787838164],
  ["06462","El Dorado","06462020","Localidad simple",-34.6528608747523,-61.5829085058874],
  ["06462","Fortín Acha","06462030","Localidad simple",-34.3430420274498,-61.5156655267072],
  ["06462","Juan Bautista Alberdi","06462040","Localidad simple",-34.4387919326349,-61.8121893821736],
  ["06462","Leandro N. Alem","06462050","Localidad simple",-34.5217246234597,-61.3911828994839],
  ["06462","Vedia","06462060","Localidad simple",-34.4973984349932,-61.5453447631478],
  ["06469","Arenaza","06469010","Localidad simple",-34.9846043002154,-61.7729116988591],
  ["06469","Bayauca","06469020","Localidad simple",-34.8710511337121,-61.2895451446375],
  ["06469","Bermúdez","06469030","Localidad simple",-34.6966047108596,-61.3250128810539],
  ["06469","Carlos Salas","06469040","Localidad simple",-35.3913662871435,-61.9949102331932],
  ["06469","Coronel Martínez de Hoz","06469050","Localidad simple",-35.3321817215807,-61.6140851684372],
  ["06469","El Triunfo","06469060","Localidad simple",-35.0882210775847,-61.5163333232821],
  ["06469","Las Toscas","06469070","Localidad simple",-35.3649873001768,-61.8055485519284],
  ["06469","Lincoln","06469080","Localidad simple",-34.869042222818,-61.5291649669285],
  ["06469","Pasteur","06469090","Localidad simple",-35.1426386337075,-62.2439028944601],
  ["06469","Roberts","06469100","Localidad simple",-35.1440875676884,-61.9707859541264],
  ["06469","Triunvirato","06469110","Localidad simple",-34.6758379792472,-61.4657087059048],
  ["06476","Arenas Verdes","06476010","Localidad simple",-38.5463782386967,-58.557322112625],
  ["06476","Licenciado Matienzo","06476020","Localidad simple",-37.9097927118145,-58.9120965943061],
  ["06476","Lobería","06476030","Localidad simple",-38.165273387122,-58.7822303314999],
  ["06476","Pieres","06476040","Localidad simple",-38.3962306181995,-58.670580006548],
  ["06476","San Manuel","06476050","Localidad simple",-37.7892829007834,-58.8486476710495],
  ["06476","Tamangueyú","06476060","Localidad simple",-38.2010112434137,-58.7373143964601],
  ["06483","Antonio Carboni","06483010","Localidad simple",-35.2033088915799,-59.3449562581802],
  ["06483","Elvira","06483020","Localidad simple",-35.243272141682,-59.4860397931491],
  ["06483","Laguna de Lobos","06483030","Localidad simple",-35.2747624905943,-59.1339060011927],
  ["06483","Lobos","06483040","Localidad simple",-35.1858677983922,-59.0957115706922],
  ["06483","Salvador María","06483050","Localidad simple",-35.3028071422894,-59.1696841440202],
  ["06490","Lomas de Zamora","06490010","Componente de localidad compuesta",-34.7611602446537,-58.3987660554104],
  ["06497","Carlos Keen","06497020","Localidad simple",-34.4862819813638,-59.2180861330698],
  ["06497","Club de Campo Los Puentes","06497025","Localidad simple",-34.5760126891974,-59.0214105976263],
  ["06497","Luján","06497060","Localidad simple",-34.5706550661631,-59.109540176033],
  ["06497","Olivera","06497070","Localidad simple",-34.6265041710141,-59.2533805145177],
  ["06497","Torres","06497090","Localidad simple",-34.4318215080317,-59.1287739002816],
  ["06505","Atalaya","06505010","Localidad simple",-35.0240363457416,-57.5340253600961],
  ["06505","General Mansilla","06505020","Localidad simple",-35.0816834306862,-57.7469762592144],
  ["06505","Los Naranjos","06505030","Localidad simple",-34.99655185849,-57.7036642458572],
  ["06505","Magdalena","06505040","Localidad simple",-35.0806853032506,-57.5172585839911],
  ["06505","Roberto J. Payró","06505050","Localidad simple",-35.1799267057869,-57.651986019808],
  ["06505","Vieytes","06505060","Localidad simple",-35.269568396303,-57.5757117447539],
  ["06511","Las Armas","06511010","Localidad simple",-37.0860540989,-57.8285752273883],
  ["06511","Maipú","06511020","Localidad simple",-36.8648514645038,-57.8829166198472],
  ["06511","Santo Domingo","06511030","Localidad simple",-36.7137597811284,-57.5860126519926],
  ["06515","Malvinas Argentinas","06515010","Componente de localidad compuesta",-34.4941030304424,-58.7005058220394],
  ["06014","Juan E. Barra","06014030","Localidad simple",-37.8233871716044,-60.484639770555],
  ["06063","Napaleofú","06063030","Localidad simple",-37.6254980210026,-58.7461862359423],
  ["06518","Coronel Vidal","06518010","Localidad simple",-37.452214188593,-57.7299500229319],
  ["06518","General Pirán","06518020","Localidad simple",-37.2778606745914,-57.7740148170474],
  ["06518","La Armonía","06518030","Localidad simple",-37.774854850113,-57.6351210747907],
  ["06518","Mar Chiquita","06518040","Localidad simple",-37.7462581727647,-57.4274479339348],
  ["06518","Mar de Cobo","06518050","Localidad simple",-37.7711670626007,-57.4521689795217],
  ["06518","Santa Clara del Mar","06518060","Localidad simple",-37.8362727356321,-57.5079699159083],
  ["06518","Vivoratá","06518070","Localidad simple",-37.6627994476991,-57.6670967441538],
  ["06525","Barrio Santa Rosa","06525010","Localidad simple",-34.953080822173,-58.78292863718],
  ["06525","Marcos Paz","06525020","Componente de localidad compuesta",-34.7800219917336,-58.8335252686468],
  ["06532","Goldney","06532005","Localidad simple",-34.6029546709308,-59.288213732192],
  ["06532","Gowland","06532010","Localidad simple",-34.652429281715,-59.3523186300108],
  ["06532","Mercedes","06532020","Localidad simple",-34.6521715354886,-59.4295981722688],
  ["06532","Jorge Born","06532030","Localidad simple",-34.6989555549409,-59.3194428313109],
  ["06539","Merlo","06539010","Componente de localidad compuesta",-34.6673332854112,-58.7284902221094],
  ["06547","Abbott","06547010","Localidad simple",-35.2825062106661,-58.8042619084921],
  ["06547","San Miguel del Monte","06547020","Localidad simple",-35.4391643240479,-58.8094598355672],
  ["06547","Zenón Videla Dorna","06547030","Localidad simple",-35.5447734044526,-58.8855911917932],
  ["06553","Balneario Sauce Grande","06553010","Localidad simple",-38.9953576913349,-61.2152015930805],
  ["06553","Monte Hermoso","06553020","Localidad simple",-38.9815065384254,-61.3005457486605],
  ["06560","Moreno","06560010","Componente de localidad compuesta",-34.6484562002299,-58.787037631993],
  ["06568","Morón","06568010","Componente de localidad compuesta",-34.6485927855745,-58.6221005158761],
  ["06574","José Juan Almeyra","06574010","Localidad simple",-34.9232643360691,-59.5422519447044],
  ["06574","Las Marianas","06574020","Localidad simple",-35.0539263781559,-59.5131011825281],
  ["06574","Navarro","06574030","Localidad simple",-35.0036066018879,-59.2774163163898],
  ["06574","Villa Moll","06574040","Localidad simple",-35.0782490606759,-59.651945539681],
  ["06581","Claraz","06581010","Localidad simple",-37.8918269607856,-59.2866977775565],
  ["06581","Energía","06581025","Localidad simple",-38.5580125335608,-59.3364566671065],
  ["06581","Juan N. Fernández","06581030","Localidad simple",-38.0091787783017,-59.263498834782],
  ["06581","Necochea - Quequén","06581040","Localidad simple",-38.5556106716458,-58.7383396197417],
  ["06581","Nicanor Olivera","06581050","Localidad simple",-38.2846361959918,-59.202754253612],
  ["06581","Ramón Santamarina","06581060","Localidad simple",-38.4503897333336,-59.3311154416146],
  ["06588","Alfredo Demarchi","06588010","Localidad simple",-35.2929819536873,-61.4072542128],
  ["06588","Carlos María Naón","06588020","Localidad simple",-35.239499381663,-60.8251358750153],
  ["06588","12 de Octubre","06588030","Localidad simple",-35.607730780146,-60.9182929927645],
  ["06588","Dudignac","06588040","Localidad simple",-35.6511928511123,-60.7098962799093],
  ["06588","La Aurora","06588050","Localidad simple",-35.4079467934431,-61.210566820487],
  ["06588","Manuel B. Gonnet","06588060","Localidad simple",-35.5201414507378,-60.9989487976537],
  ["06588","Marcelino Ugarte","06588070","Localidad simple",-35.3462662593318,-60.7453446826815],
  ["06588","Norumbega","06588090","Localidad simple",-35.5357392707567,-60.7928143632315],
  ["06588","9 de Julio","06588100","Localidad simple",-35.4447435053964,-60.8843433362718],
  ["06588","Patricios","06588110","Localidad simple",-35.4395526972374,-60.7174384712323],
  ["06588","Villa Fournier","06588120","Localidad simple",-35.4989239490928,-60.8647207106461],
  ["06595","Blancagrande","06595010","Localidad simple",-36.5328887082639,-60.8824549132602],
  ["06595","Colonia Nievas","06595030","Localidad simple",-36.8641370257955,-60.0816424703999],
  ["06595","Colonia San Miguel","06595040","Localidad simple",-36.9495659791886,-60.1108954083182],
  ["06595","Espigas","06595050","Localidad simple",-36.4122732396335,-60.6730694647],
  ["06595","Hinojo","06595060","Localidad simple",-36.8805120719062,-60.1771940245472],
  ["06595","Olavarría","06595070","Localidad simple",-36.8920935788859,-60.3180046559577],
  ["06595","Recalde","06595080","Localidad simple",-36.6515016172821,-61.0845040269814],
  ["06595","Santa Luisa","06595090","Localidad simple",-37.128965369352,-60.4099303899854],
  ["06595","Sierra Chica","06595100","Localidad simple",-36.8432382225239,-60.2234271381196],
  ["06595","Sierras Bayas","06595110","Localidad simple",-36.9320807590695,-60.1616034851477],
  ["06595","Villa Alfredo Fortabat","06595120","Localidad simple",-36.9802714637124,-60.2790828437139],
  ["06595","Villa La Serranía","06595130","Localidad simple",-36.9903632120511,-60.3108081181748],
  ["06602","Bahía San Blas","06602010","Localidad simple",-40.5602246137406,-62.2380643077459],
  ["06602","Cardenal Cagliero","06602020","Localidad simple",-40.6522000086693,-62.7575972084464],
  ["06602","Carmen de Patagones","06602030","Componente de localidad compuesta",-40.797298324401,-62.984754269904],
  ["06602","José B. Casas","06602040","Localidad simple",-40.4363643935514,-62.5449343513868],
  ["06602","Juan A. Pradere","06602050","Localidad simple",-39.5993801239416,-62.6510470779021],
  ["06602","Stroeder","06602060","Localidad simple",-40.1854869993736,-62.6205163469861],
  ["06602","Villalonga","06602070","Localidad simple",-39.9151387867694,-62.6188702678852],
  ["06609","Capitán Castro","06609010","Localidad simple",-35.913692884071,-62.2240579143551],
  ["06609","San Esteban","06609020","Localidad simple",-35.7327373193414,-61.7439272931387],
  ["06609","Francisco Madero","06609030","Localidad simple",-35.8483065194137,-62.0693918423116],
  ["06609","Inocencio Sosa","06609035","Localidad simple",-35.7184196474894,-62.1142777365421],
  ["06609","Juan José Paso","06609040","Localidad simple",-35.8524740557321,-62.2962123802194],
  ["06609","Magdala","06609050","Localidad simple",-36.0846707903374,-61.7254747841859],
  ["06609","Mones Cazón","06609060","Localidad simple",-36.2301776476091,-62.0069944091925],
  ["06609","Nueva Plata","06609070","Localidad simple",-35.9199117438484,-61.8133995164977],
  ["06609","Pehuajó","06609080","Localidad simple",-35.8123030689596,-61.8988207561037],
  ["06609","San Bernardo","06609090","Localidad simple",-35.7137365347985,-61.6477830181101],
  ["06616","Bocayuva","06616010","Localidad simple",-36.2079529825985,-63.0771172663474],
  ["06616","De Bary","06616020","Localidad simple",-36.3416806655424,-63.2611533171506],
  ["06616","Pellegrini","06616030","Localidad simple",-36.2697352282386,-63.1652861097016],
  ["06623","Acevedo","06623010","Localidad simple",-33.755665348987,-60.4408373865386],
  ["06623","Fontezuela","06623020","Localidad simple",-33.9138392371386,-60.4628650932084],
  ["06623","Guerrico","06623030","Localidad simple",-33.6745849638169,-60.400686593861],
  ["06623","Juan A. de la Peña","06623040","Localidad simple",-33.8322767381075,-60.4864895356948],
  ["06623","Juan Anchorena","06623050","Localidad simple",-33.9263378592898,-60.3829034809436],
  ["06623","La Violeta","06623060","Localidad simple",-33.7347851403163,-60.1701773086428],
  ["06623","Manuel Ocampo","06623070","Localidad simple",-33.7647232673599,-60.6492429333859],
  ["06623","Mariano Benítez","06623080","Localidad simple",-33.7090270411103,-60.5842599045876],
  ["06623","Mariano H. Alfonzo","06623090","Localidad simple",-33.9149979004605,-60.8383550657724],
  ["06623","Pergamino","06623100","Localidad simple",-33.8949900563191,-60.5716400794952],
  ["06623","Pinzón","06623110","Localidad simple",-33.9947211174052,-60.7316480040989],
  ["06623","Rancagua","06623120","Localidad simple",-34.0303722475767,-60.5042327001336],
  ["06623","Villa Angélica","06623130","Localidad simple",-33.6647037443081,-60.7084372635626],
  ["06623","Villa San José","06623140","Componente de localidad compuesta",-34.0906695795004,-60.4162716627136],
  ["06630","Casalins","06630010","Localidad simple",-36.3181419923689,-58.5525025522873],
  ["06630","Pila","06630020","Localidad simple",-36.0014746137723,-58.1427778873885],
  ["06638","Pilar","06638040","Componente de localidad compuesta",-34.4564820970471,-58.9147241864112],
  ["06644","Pinamar","06644010","Localidad simple",-37.1035436553232,-56.8484282535998],
  ["06648","Presidente Perón","06648010","Componente de localidad compuesta",-34.9165952571677,-58.378782412589],
  ["06651","Azopardo","06651010","Localidad simple",-37.7017920523646,-62.9006764415683],
  ["06651","Bordenave","06651020","Localidad simple",-37.8028181597411,-63.0425144041162],
  ["06651","Darregueira","06651030","Localidad simple",-37.6857562622736,-63.1595663902141],
  ["06651","17 de Agosto","06651040","Localidad simple",-37.9086924428976,-62.9360284730803],
  ["06651","Estela","06651050","Localidad simple",-38.1080950084855,-62.9129041375994],
  ["06651","Felipe Solá","06651060","Localidad simple",-38.005992834739,-62.8186936682637],
  ["06651","López Lecube","06651070","Localidad simple",-38.1171190117962,-62.7254849373447],
  ["06651","Puán","06651080","Localidad simple",-37.542613502113,-62.7652275731166],
  ["06651","San Germán","06651090","Localidad simple",-38.2995183581309,-62.9821877089624],
  ["06651","Villa Castelar","06651100","Localidad simple",-37.3905464925651,-62.8051325654187],
  ["06651","Villa Iris","06651110","Localidad simple",-38.1693097057753,-63.2320511809102],
  ["06655","Pipinas","06655030","Localidad simple",-35.5312670691699,-57.3285887617048],
  ["06655","Punta Indio","06655040","Localidad simple",-35.2808352898088,-57.2360072391524],
  ["06655","Verónica","06655050","Localidad simple",-35.3881552142501,-57.3371601623743],
  ["06658","Quilmes","06658010","Componente de localidad compuesta",-34.724691432384,-58.2613407434763],
  ["06665","El Paraíso","06665010","Localidad simple",-33.5679152654444,-59.9791123483107],
  ["06665","Las Bahamas","06665020","Localidad simple",-33.6366100825527,-59.9895563465816],
  ["06665","Pérez Millán","06665030","Localidad simple",-33.7674497804832,-60.0927343667154],
  ["06665","Ramallo","06665040","Localidad simple",-33.4877021169888,-60.0072209741607],
  ["06665","Villa General Savio","06665050","Localidad simple",-33.4352672179447,-60.1451316522293],
  ["06665","Villa Ramallo","06665060","Localidad simple",-33.502293213764,-60.0650138035308],
  ["06672","Rauch","06672010","Localidad simple",-36.7755035485732,-59.0871114029954],
  ["06679","América","06679010","Localidad simple",-35.4903412429492,-62.9763759840765],
  ["06679","Fortín Olavarría","06679020","Localidad simple",-35.7048848499519,-63.02303327525],
  ["06679","González Moreno","06679030","Localidad simple",-35.5576529256075,-63.3815800402316],
  ["06679","Mira Pampa","06679040","Localidad simple",-35.8703867348478,-63.3742010687724],
  ["06679","Roosevelt","06679050","Localidad simple",-35.8466320155134,-63.2898118317476],
  ["06679","San Mauricio","06679060","Localidad simple",-35.5118022821456,-63.1882154861262],
  ["06679","Sansinena","06679070","Localidad simple",-35.2750295400617,-63.2135436741919],
  ["06679","Sundblad","06679080","Localidad simple",-35.7656416636683,-63.1386100973601],
  ["06686","La Beba","06686010","Localidad simple",-34.1544387870912,-61.0128711169321],
  ["06686","Las Carabelas","06686020","Localidad simple",-34.0381002651925,-60.8685264174218],
  ["06686","Los Indios","06686030","Localidad simple",-34.3735696107802,-60.6523710265627],
  ["06686","Rafael Obligado","06686040","Localidad simple",-34.3588132488617,-60.7845693256007],
  ["06686","Roberto Cano","06686050","Localidad simple",-34.0876515179763,-60.6672564006968],
  ["06686","Rojas","06686060","Localidad simple",-34.1961600446015,-60.7332636467146],
  ["06686","Sol de Mayo","06686070","Localidad simple",-34.2689448512236,-60.871777342098],
  ["06686","Villa Manuel Pomar","06686080","Componente de localidad compuesta",-33.9159508805463,-60.9379380238883],
  ["06693","Carlos Beguerie","06693010","Localidad simple",-35.4854690457283,-59.1017155978911],
  ["06693","Roque Pérez","06693020","Localidad simple",-35.4016375824204,-59.3346857845207],
  ["06700","Arroyo Corto","06700010","Localidad simple",-37.5129179734769,-62.3116837747426],
  ["06700","Colonia San Martín","06700020","Localidad simple",-37.9769152091142,-62.3326095560459],
  ["06700","Dufaur","06700030","Localidad simple",-37.9428223013645,-62.284864272698],
  ["06700","Espartillar","06700040","Componente de localidad compuesta",-37.3604343942367,-62.4297386825705],
  ["06700","Goyena","06700050","Localidad simple",-37.7192518502325,-62.6071296330023],
  ["06700","Las Encadenadas","06700055","Localidad simple",-38.0361082716296,-62.4704140736323],
  ["06700","Pigüé","06700060","Localidad simple",-37.6063896033626,-62.4057728759142],
  ["06700","Saavedra","06700070","Localidad simple",-37.7636402199499,-62.3506328041255],
  ["06707","Álvarez de Toledo","06707010","Localidad simple",-35.6391609182127,-59.6292383440582],
  ["06707","Cazón","06707030","Localidad simple",-35.576803202395,-59.6645037628687],
  ["06707","Del Carril","06707040","Localidad simple",-35.5127172285926,-59.5158202035334],
  ["06707","Polvaredas","06707050","Localidad simple",-35.5939072311549,-59.5079734849201],
  ["06707","Saladillo","06707060","Localidad simple",-35.6404298805989,-59.7790589845354],
  ["06714","Arroyo Dulce","06714010","Componente de localidad compuesta",-34.1024332833136,-60.4061551794069],
  ["06714","Berdier","06714020","Localidad simple",-34.3987726587976,-60.2605725409335],
  ["06714","Gahan","06714030","Localidad simple",-34.3380744009945,-60.0992736191527],
  ["06714","Inés Indart","06714040","Localidad simple",-34.3994163305262,-60.5436825925267],
  ["06714","La Invencible","06714050","Localidad simple",-34.2687422037239,-60.3853645216588],
  ["06714","Salto","06714060","Localidad simple",-34.2921598652878,-60.2546244496406],
  ["06721","Quenumá","06721010","Localidad simple",-36.5689908284906,-63.0876229573465],
  ["06721","Salliqueló","06721020","Localidad simple",-36.7511653813281,-62.9599573443115],
  ["06728","Azcuénaga","06728010","Localidad simple",-34.3637910907784,-59.3745991110996],
  ["06728","Cucullú","06728020","Localidad simple",-34.4460870677999,-59.3622553297801],
  ["06728","Franklin","06728030","Localidad simple",-34.6103908719397,-59.6301795182439],
  ["06728","San Andrés de Giles","06728040","Localidad simple",-34.4459080814748,-59.4451673563949],
  ["06728","Solís","06728050","Localidad simple",-34.2989712949513,-59.3250547278241],
  ["06728","Villa Espil","06728060","Localidad simple",-34.506681404481,-59.3372661316763],
  ["06728","Villa Ruiz","06728070","Localidad simple",-34.4352021828488,-59.260395880426],
  ["06735","Duggan","06735010","Localidad simple",-34.2071973030208,-59.6357055338083],
  ["06735","San Antonio de Areco","06735020","Localidad simple",-34.2503763113877,-59.4708634797005],
  ["06735","Villa Lía","06735030","Localidad simple",-34.1237740718192,-59.4313725724126],
  ["06742","Balneario San Cayetano","06742010","Localidad simple",-38.7481815016452,-59.429204589717],
  ["06742","Ochandío","06742020","Localidad simple",-38.3598244506044,-59.7935349347064],
  ["06742","San Cayetano","06742030","Localidad simple",-38.346970946847,-59.6063826058005],
  ["06749","San Fernando","06749010","Componente de localidad compuesta",-34.4418003197061,-58.5580198721145],
  ["06756","San Isidro","06756010","Componente de localidad compuesta",-34.4721541217739,-58.5109710038312],
  ["06760","San Miguel","06760010","Componente de localidad compuesta",-34.5438144507937,-58.712723882421],
  ["06763","Conesa","06763010","Localidad simple",-33.5962124822607,-60.3541264450857],
  ["06763","Erezcano","06763020","Localidad simple",-33.5232449410318,-60.3174454958625],
  ["06763","General Rojo","06763030","Localidad simple",-33.4758683523603,-60.2874270636731],
  ["06763","La Emilia","06763040","Localidad simple",-33.3504137209751,-60.31414686162],
  ["06763","San Nicolás de los Arroyos","06763050","Componente de localidad compuesta",-33.334698916599,-60.2183974475905],
  ["06763","Villa Esperanza","06763060","Localidad simple",-33.422326147095,-60.2605874904382],
  ["06770","Gobernador Castro","06770010","Localidad simple",-33.6605787290919,-59.8663408291494],
  ["06770","Ingeniero Moneta","06770015","Localidad simple",-33.9314631330704,-59.7482330053997],
  ["06770","Obligado","06770020","Localidad simple",-33.5965558617631,-59.8199792397796],
  ["06770","Pueblo Doyle","06770030","Localidad simple",-33.9050057189811,-59.8187532271261],
  ["06770","Río Tala","06770040","Localidad simple",-33.769589927701,-59.6383708591324],
  ["06770","San Pedro","06770050","Localidad simple",-33.6791252253366,-59.6668951027895],
  ["06770","Santa Lucía","06770060","Localidad simple",-33.8794559527188,-59.8753284459434],
  ["06778","San Vicente","06778020","Componente de localidad compuesta",-35.0240394387399,-58.4205914420453],
  ["06784","General Rivas","06784010","Localidad simple",-34.6100370680434,-59.7504234207745],
  ["06784","Suipacha","06784020","Localidad simple",-34.7712617839883,-59.6879181821818],
  ["06791","De la Canal","06791010","Localidad simple",-37.1293125663243,-59.105380206456],
  ["06791","Gardey","06791030","Localidad simple",-37.2823323375205,-59.3630004748452],
  ["06791","María Ignacia","06791040","Localidad simple",-37.4029073074266,-59.5093354449092],
  ["06791","Tandil","06791050","Localidad simple",-37.3238849060878,-59.1310691770429],
  ["06798","Crotto","06798010","Localidad simple",-36.5774103919485,-60.1711185359918],
  ["06798","Tapalqué","06798020","Localidad simple",-36.3573669882462,-60.0247443487218],
  ["06798","Velloso","06798030","Localidad simple",-36.1215309084723,-59.6527146246681],
  ["06805","Tigre","06805010","Componente de localidad compuesta",-34.4256910710843,-58.5810472651652],
  ["06812","General Conesa","06812010","Localidad simple",-36.5208587437818,-57.3249371025507],
  ["06819","Chasicó","06819010","Localidad simple",-38.3352258409739,-62.6424099899733],
  ["06819","Saldungaray","06819020","Localidad simple",-38.2028131038038,-61.7678925154653],
  ["06819","Sierra de la Ventana","06819030","Componente de localidad compuesta",-38.1366716139365,-61.7956860399239],
  ["06819","Tornquist","06819040","Localidad simple",-38.0989983131157,-62.2218091270044],
  ["06819","Tres Picos","06819050","Localidad simple",-38.2867749310339,-62.2073117423093],
  ["06819","La Gruta","06819060","Localidad simple",-38.0568266332177,-62.0782618310425],
  ["06819","Villa Ventana","06819070","Localidad simple",-38.0795765714478,-61.9311383483155],
  ["06826","Berutti","06826010","Localidad simple",-35.8580311359835,-62.5126328995628],
  ["06826","Girodias","06826020","Localidad simple",-36.367451804132,-62.3569660936558],
  ["06826","La Carreta","06826030","Localidad simple",-36.1964811594442,-62.2245641400875],
  ["06826","30 de Agosto","06826040","Localidad simple",-36.2779720057322,-62.5453088654651],
  ["06826","Trenque Lauquen","06826050","Localidad simple",-35.9746951559846,-62.7323099655579],
  ["06826","Trongé","06826060","Localidad simple",-36.4603092402658,-62.4871229040303],
  ["06833","Balneario Orense","06833010","Localidad simple",-38.8079580951783,-59.7382989446997],
  ["06833","Claromecó","06833020","Localidad simple",-38.8574731904502,-60.0730577260656],
  ["06833","Copetonas","06833030","Localidad simple",-38.7227403438549,-60.4519655195991],
  ["06833","Lin Calel","06833040","Localidad simple",-38.7081778337076,-60.2417246463467],
  ["06833","Micaela Cascallares","06833050","Localidad simple",-38.4926790060303,-60.4684232796744],
  ["06833","Orense","06833060","Localidad simple",-38.6855169253542,-59.7764287092023],
  ["06833","Reta","06833070","Localidad simple",-38.8970805514765,-60.3434097916689],
  ["06833","San Francisco de Bellocq","06833080","Localidad simple",-38.6931705173547,-60.0141786926695],
  ["06833","San Mayol","06833090","Localidad simple",-38.3177365227323,-60.0258421214842],
  ["06833","Tres Arroyos","06833100","Localidad simple",-38.3771785795114,-60.2755588939396],
  ["06833","Villa Rodríguez","06833110","Localidad simple",-38.3125817693893,-60.2324995777757],
  ["06840","Tres de Febrero","06840010","Componente de localidad compuesta",-34.6048497158582,-58.5609615725508],
  ["06847","Ingeniero Thompson","06847010","Localidad simple",-36.6102541131892,-62.9109612139671],
  ["06847","Tres Lomas","06847020","Localidad simple",-36.458109497037,-62.8621355091327],
  ["06854","Agustín Mosconi","06854010","Localidad simple",-35.7392169542026,-60.5590634621789],
  ["06854","Del Valle","06854020","Localidad simple",-35.8973453887603,-60.7316089512944],
  ["06854","Ernestina","06854030","Localidad simple",-35.2702340519789,-59.5575034078873],
  ["06854","Gobernador Ugarte","06854040","Localidad simple",-35.1643973648092,-60.0813577815068],
  ["06854","Lucas Monteverde","06854050","Localidad simple",-35.4838272164734,-59.9880647932831],
  ["06854","Norberto de la Riestra","06854060","Localidad simple",-35.2727788695321,-59.7719327250509],
  ["06854","Pedernales","06854070","Localidad simple",-35.2666085074293,-59.6306574695383],
  ["06854","San Enrique","06854080","Localidad simple",-35.7785028686085,-60.3546454811901],
  ["06854","Valdés","06854090","Localidad simple",-35.6488128268596,-60.4672591673156],
  ["06854","25 de Mayo","06854100","Localidad simple",-35.4339385892588,-60.1731209454056],
  ["06861","Vicente López","06861010","Componente de localidad compuesta",-34.5085008473315,-58.4816394249184],
  ["06868","Mar Azul","06868010","Localidad simple",-37.3359116629584,-57.0313877628295],
  ["06868","Villa Gesell","06868020","Localidad simple",-37.24647046985,-56.9707267624406],
  ["06875","Argerich","06875010","Localidad simple",-38.7686560837266,-62.6025276771033],
  ["06875","Colonia San Adolfo","06875020","Localidad simple",-39.3983952518232,-62.5711721088672],
  ["06875","Country Los Medanos","06875025","Localidad simple",-38.8468445915571,-62.7387418858309],
  ["06875","Hilario Ascasubi","06875030","Localidad simple",-39.3758602632663,-62.6477900877351],
  ["06875","Juan Cousté","06875040","Localidad simple",-38.8942604188727,-63.1361581918897],
  ["06875","Mayor Buratovich","06875050","Localidad simple",-39.2590946793617,-62.6157889589915],
  ["06875","Médanos","06875060","Localidad simple",-38.825840065805,-62.6958221431755],
  ["06875","Pedro Luro","06875070","Localidad simple",-39.5007767274615,-62.6874317159849],
  ["06875","Teniente Origone","06875080","Localidad simple",-39.0580586668564,-62.5697137402023],
  ["06882","Country Club El Casco","06882020","Localidad simple",-34.1275885141615,-59.0834596008166],
  ["06882","Escalada","06882030","Localidad simple",-34.160933188334,-59.112539983688],
  ["06882","Zárate","06882050","Localidad simple",-34.0998630672257,-59.0245572551519],
  ["10007","Chuchucaruana","10007010","Localidad simple",-27.9072844349135,-65.8265242094263],
  ["10007","Colpes","10007020","Localidad simple",-28.056472497625,-65.8260844153652],
  ["10007","El Bolsón","10007030","Localidad simple",-27.9038743420396,-65.8884829262542],
  ["10007","El Rodeo","10007040","Localidad simple",-28.2141516424861,-65.8738600634115],
  ["10007","Huaycama","10007050","Localidad simple",-28.0988458342304,-65.8147464336478],
  ["10007","La Puerta","10007060","Localidad simple",-28.1764379052117,-65.7863037835082],
  ["10007","Las Chacritas","10007070","Localidad simple",-27.6464168267027,-65.9533446470457],
  ["10007","Las Juntas","10007080","Localidad simple",-28.1038836314671,-65.8996513641899],
  ["10007","Los Castillos","10007090","Localidad simple",-27.9582295650792,-65.8206857233129],
  ["10007","Los Talas","10007100","Localidad simple",-27.94999754917,-65.875829814164],
  ["10007","Los Varela","10007110","Localidad simple",-27.9279942328057,-65.8822302327591],
  ["10007","Singuil","10007120","Localidad simple",-27.8142168571341,-65.8670660017181],
  ["10014","Ancasti","10014010","Localidad simple",-28.809829766706,-65.5021019996524],
  ["10014","Anquincila","10014020","Localidad simple",-28.7545936474404,-65.5495102803337],
  ["10014","La Candelaria","10014030","Localidad simple",-28.7207622901373,-65.4106917370235],
  ["10014","La Majada","10014040","Localidad simple",-29.0295107636719,-65.5499567687055],
  ["10021","Amanao","10021010","Localidad simple",-27.5275895579827,-66.5156761677031],
  ["10021","Andalgalá","10021020","Localidad simple",-27.5732225954972,-66.3235466394645],
  ["10021","Chaquiago","10021030","Localidad simple",-27.5368955481985,-66.3350568927423],
  ["10021","Choya","10021040","Localidad simple",-27.5210749343604,-66.4034742805443],
  ["10021","El Alamito","10021050","Localidad simple",-27.3442239666896,-66.0262150249926],
  ["10021","El Lindero","10021060","Localidad simple",-27.4399620378037,-66.0126636437218],
  ["10021","El Potrero","10021070","Localidad simple",-27.5162322380357,-66.3434280762552],
  ["10021","La Aguada","10021080","Localidad simple",-27.534089032104,-66.3117750484601],
  ["10028","Antofagasta de la Sierra","10028010","Localidad simple",-26.0632957365736,-67.4116706391736],
  ["10028","Antofalla","10028020","Localidad simple",-25.445326397371,-67.6583954684647],
  ["10028","El Peñón","10028030","Localidad simple",-26.4377795455164,-67.2590953594946],
  ["10028","Los Nacimientos","10028040","Localidad simple",-25.7592665755338,-67.3912671398198],
  ["10035","Barranca Larga","10035010","Localidad simple",-26.9366725902001,-66.7473736733687],
  ["10035","Belén","10035020","Localidad simple",-27.6337582271366,-67.0181224346383],
  ["10035","Cóndor Huasi","10035030","Localidad simple",-27.4800253698881,-67.1034365555174],
  ["10035","Corral Quemado","10035040","Localidad simple",-27.1458266170631,-66.9418772140389],
  ["10035","El Durazno","10035050","Localidad simple",-27.2352160693092,-67.0644302349354],
  ["10035","Farallón Negro","10035060","Localidad simple",-27.297991160481,-66.6526535881206],
  ["10035","Hualfín","10035070","Localidad simple",-27.2251089488391,-66.8257494663378],
  ["10035","Jacipunco","10035080","Localidad simple",-27.2232502935304,-67.0189560597067],
  ["10035","La Puntilla","10035090","Localidad simple",-27.6687999477098,-66.9831854181016],
  ["10035","Las Juntas","10035100","Localidad simple",-27.5255267279244,-67.1230327103174],
  ["10035","Londres","10035110","Localidad simple",-27.7091441699136,-67.1521288574758],
  ["10035","Los Nacimientos","10035120","Localidad simple",-27.1276313861506,-66.7125336324121],
  ["10035","Puerta de Corral Quemado","10035130","Localidad simple",-27.2142919344438,-66.9263178640934],
  ["10035","Puerta de San José","10035140","Localidad simple",-27.5397412070942,-67.0153310519752],
  ["10035","Villa Vil","10035150","Localidad simple",-27.0710806751114,-66.8307696967368],
  ["10042","Adolfo E. Carranza","10042010","Localidad simple",-29.0269775235925,-65.9719315369665],
  ["10042","Balde de la Punta","10042020","Localidad simple",-29.5589484234071,-65.5807240749041],
  ["10042","Capayán","10042030","Localidad simple",-28.7807106449765,-66.0386455444458],
  ["10042","Chumbicha","10042040","Localidad simple",-28.8475652676601,-66.2413567840967],
  ["10042","Colonia del Valle","10042050","Localidad simple",-28.6659572317315,-65.8752053335171],
  ["10042","Colonia Nueva Coneta","10042060","Localidad simple",-28.5859218596167,-65.8384330489801],
  ["10042","Concepción","10042070","Localidad simple",-28.7027878127673,-66.0684404425234],
  ["10042","Coneta","10042080","Localidad simple",-28.5824940471212,-65.8832899522771],
  ["10042","El Bañado","10042090","Localidad simple",-28.6492910442286,-65.8184083876596],
  ["10042","Huillapima","10042100","Localidad simple",-28.7326533523263,-65.9692671337205],
  ["10042","Los Angeles","10042110","Localidad simple",-28.4757282890296,-65.9584714095267],
  ["10042","Miraflores","10042120","Localidad simple",-28.61156437771,-65.9045510608673],
  ["10042","San Martín","10042130","Localidad simple",-29.2514238184412,-65.7966971627176],
  ["10042","San Pablo","10042140","Localidad simple",-28.7185211619111,-66.0406031753627],
  ["10042","San Pedro","10042150","Localidad simple",-28.7717177596284,-66.1240600986815],
  ["10049","El Pantanillo","10049020","Localidad simple",-28.5416893432334,-65.8026632730873],
  ["10049","San Fernando del Valle de Catamarca","10049030","Componente de localidad compuesta",-28.4846581947085,-65.786789293763],
  ["10056","El Alto","10056010","Localidad simple",-28.3027477561138,-65.369376719249],
  ["10056","Guayamba","10056020","Localidad simple",-28.3441266642037,-65.4127476684157],
  ["10056","Infanzón","10056030","Localidad simple",-28.5973244077887,-65.4116602658917],
  ["10056","Los Corrales","10056040","Localidad simple",-28.5108290239161,-65.3308772218931],
  ["10056","Tapso","10056050","Componente de localidad compuesta",-28.4159041977159,-65.1086409589416],
  ["10056","Vilismán","10056060","Localidad simple",-28.5021133153073,-65.4385489995235],
  ["10063","Collagasta","10063010","Localidad simple",-28.3616776397898,-65.7282690165025],
  ["10063","Pomancillo Este","10063020","Localidad simple",-28.3087173740113,-65.7222098439933],
  ["10063","Pomancillo Oeste","10063030","Localidad simple",-28.3178432457188,-65.7423447192214],
  ["10063","San José","10063040","Componente de localidad compuesta",-28.4017030273125,-65.7123014190702],
  ["10063","Villa Las Pirquitas","10063050","Localidad simple",-28.2754665210832,-65.733431477509],
  ["10070","Casa de Piedra","10070010","Localidad simple",-29.649289010725,-65.5171151597056],
  ["10070","El Aybal","10070020","Localidad simple",-29.1066140404485,-65.339695207396],
  ["10070","El Bañado","10070030","Localidad simple",-29.1832354089391,-65.4161459216901],
  ["10070","El Divisadero","10070040","Localidad simple",-29.193718415728,-65.4233403523442],
  ["10070","El Quimilo","10070050","Localidad simple",-29.9534214435134,-65.3926406151323],
  ["10070","Esquiú","10070060","Localidad simple",-29.3790661944991,-65.2898287859815],
  ["10070","Icaño","10070070","Localidad simple",-28.9308886124085,-65.2902158081111],
  ["10070","La Dorada","10070080","Localidad simple",-29.2804387843954,-65.4766321943102],
  ["10070","La Guardia","10070090","Localidad simple",-29.5496731497758,-65.4504857993817],
  ["10070","Las Esquinas","10070100","Localidad simple",-28.7644628061471,-65.1120210167305],
  ["10070","Las Palmitas","10070110","Localidad simple",-28.6402396947153,-64.9870716926629],
  ["10070","Quirós","10070120","Localidad simple",-28.7883056058069,-65.1007302335708],
  ["10070","Ramblones","10070130","Localidad simple",-29.1582844511715,-65.374945475853],
  ["10070","Recreo","10070140","Localidad simple",-29.2768611237227,-65.0565641552447],
  ["10070","San Antonio","10070150","Localidad simple",-28.9331053161662,-65.0949655869376],
  ["10077","Amadores","10077010","Localidad simple",-28.2680363798745,-65.6462108146466],
  ["10077","El Rosario","10077020","Localidad simple",-27.9877541032226,-65.688606939529],
  ["10077","La Bajada","10077030","Localidad simple",-28.3920524907261,-65.6282649899935],
  ["10077","La Higuera","10077040","Localidad simple",-27.9352828616507,-65.699367489363],
  ["10077","La Merced","10077050","Localidad simple",-28.1537649054231,-65.6696062414473],
  ["10077","La Viña","10077060","Localidad simple",-28.044445782746,-65.6079383578394],
  ["10077","Las Lajas","10077070","Localidad simple",-27.826913357423,-65.7401079267206],
  ["10077","Monte Potrero","10077080","Localidad simple",-28.19124607288,-65.670675013192],
  ["10077","Palo Labrado","10077090","Localidad simple",-28.3360934480518,-65.6274299147885],
  ["10077","San Antonio","10077100","Localidad simple",-28.0073083693979,-65.726850392729],
  ["10077","Villa de Balcozna","10077110","Localidad simple",-27.87835755933,-65.7190758944755],
  ["10084","Apoyaco","10084010","Localidad simple",-28.3006337911705,-66.1659791753183],
  ["10084","Colana","10084020","Localidad simple",-28.3432877302321,-66.1222559102194],
  ["10084","Colpes","10084030","Localidad simple",-28.0606503909838,-66.2065039006705],
  ["10084","El Pajonal","10084040","Localidad simple",-28.3773148491306,-66.3017092655098],
  ["10084","Joyango","10084050","Localidad simple",-28.0731019653889,-66.1435569766782],
  ["10084","Mutquin","10084060","Localidad simple",-28.3178455729042,-66.1420642866296],
  ["10084","Pomán","10084070","Localidad simple",-28.3927801149204,-66.2220823999264],
  ["06063","Ramos Otero","06063040","Localidad simple",-37.5426353712017,-58.3407185507274],
  ["10084","Rincón","10084080","Localidad simple",-28.2022631098292,-66.1487991328879],
  ["10084","San Miguel","10084090","Localidad simple",-28.1297413013665,-66.2019565174868],
  ["10084","Saujil","10084100","Localidad simple",-28.173337080009,-66.2145148644181],
  ["10084","Siján","10084110","Localidad simple",-28.2623558875079,-66.2209299175292],
  ["10091","Andalhualá","10091010","Localidad simple",-26.8479427341705,-66.0244068592756],
  ["10091","Caspichango","10091020","Localidad simple",-26.6859290047178,-65.970794986953],
  ["10091","Chañar Punco","10091030","Localidad simple",-26.7354113550042,-66.0434834449295],
  ["10091","El Cajón","10091040","Localidad simple",-26.3955476915097,-66.2641930164042],
  ["10091","El Desmonte","10091050","Localidad simple",-26.9077168676094,-66.020423153794],
  ["10091","El Puesto","10091060","Localidad simple",-26.6307679478767,-66.0140418967532],
  ["10091","Famatanca","10091070","Localidad simple",-26.8055410533594,-66.0592481425342],
  ["10091","Fuerte Quemado","10091080","Localidad simple",-26.6304336405934,-66.0644373734469],
  ["10091","La Hoyada","10091090","Localidad simple",-26.5189083514476,-66.3686109740362],
  ["10091","La Loma","10091100","Componente de localidad compuesta",-26.7574990827117,-66.0331064865258],
  ["10091","Las Mojarras","10091110","Localidad simple",-26.6990627613287,-66.0401662058747],
  ["10091","Loro Huasi","10091120","Componente de localidad compuesta",-26.7361383729613,-66.0217845814201],
  ["10091","Punta de Balasto","10091130","Localidad simple",-26.9300943985158,-66.1487294264287],
  ["10091","San José","10091140","Localidad simple",-26.7745564838512,-66.0347026505038],
  ["10091","Santa María","10091150","Localidad simple",-26.6891167120231,-66.0188844413109],
  ["10091","Yapes","10091160","Localidad simple",-26.8289862929732,-66.0179166770412],
  ["10098","Alijilán","10098010","Localidad simple",-28.1771812692249,-65.4915924205872],
  ["10098","Bañado de Ovanta","10098020","Localidad simple",-28.1034003361447,-65.3076846046354],
  ["10098","Las Cañas","10098030","Localidad simple",-28.2098696025062,-65.2230167049514],
  ["10098","Lavalle","10098040","Componente de localidad compuesta",-28.1946338127178,-65.1137806266473],
  ["10098","Los Altos","10098050","Localidad simple",-28.0488590493489,-65.4973640431533],
  ["10098","Manantiales","10098060","Localidad simple",-28.1469656455994,-65.5073235747446],
  ["10098","San Pedro","10098070","Componente de localidad compuesta",-27.9608485883022,-65.1680076958397],
  ["10105","Anillaco","10105010","Localidad simple",-27.9001528461069,-67.614283874159],
  ["10105","Antinaco","10105020","Localidad simple",-27.231445564254,-67.6080549409746],
  ["10105","Banda de Lucero","10105030","Localidad simple",-28.0687850626962,-67.5077024205599],
  ["10105","Cerro Negro","10105040","Localidad simple",-28.2432405441597,-67.144273179127],
  ["10105","Copacabana","10105050","Localidad simple",-28.1415680978793,-67.4904155296291],
  ["10105","Cordobita","10105060","Localidad simple",-28.2979798704965,-67.1670904449903],
  ["10105","Costa de Reyes","10105070","Localidad simple",-28.2949599230089,-67.702902490024],
  ["10105","El Pueblito","10105080","Localidad simple",-28.2888183254668,-67.1234522983543],
  ["10105","El Puesto","10105090","Localidad simple",-27.9267621470675,-67.6304002049274],
  ["10105","El Salado","10105100","Localidad simple",-28.3120206339513,-67.250879321266],
  ["10105","Fiambalá","10105110","Localidad simple",-27.6564765040882,-67.6083210338137],
  ["10105","Los Balverdis","10105120","Localidad simple",-28.2769854029709,-67.1074444099183],
  ["10105","Medanitos","10105130","Localidad simple",-27.5239130706008,-67.5891477326484],
  ["10105","Palo Blanco","10105140","Localidad simple",-27.3395852802531,-67.7592295432626],
  ["10105","Punta del Agua","10105150","Localidad simple",-27.2106668219369,-67.7317928557181],
  ["10105","Saujil","10105160","Localidad simple",-27.5632127581426,-67.6355130611556],
  ["10105","Tatón","10105170","Localidad simple",-27.3270122428844,-67.4747701838904],
  ["10105","Tinogasta","10105180","Localidad simple",-28.0637510698675,-67.5802695760226],
  ["10112","El Portezuelo","10112010","Localidad simple",-28.481868041951,-65.6351326652418],
  ["10112","Huaycama","10112020","Localidad simple",-28.5334483576648,-65.6821279512165],
  ["10112","Las Tejas","10112030","Localidad simple",-28.6468889609952,-65.7889935499028],
  ["10112","San Isidro","10112040","Componente de localidad compuesta",-28.4645930905709,-65.7273374100484],
  ["10112","Santa Cruz","10112050","Localidad simple",-28.4928946549812,-65.6744465587279],
  ["14007","Amboy","14007010","Localidad simple",-32.1759165218621,-64.5765483175138],
  ["14007","Arroyo San Antonio","14007020","Localidad simple",-32.26205146004,-64.5937253212731],
  ["14007","Cañada del Sauce","14007030","Localidad simple",-32.3679991604312,-64.6425223427633],
  ["14007","Capilla Vieja","14007040","Localidad simple",-31.9420274165289,-64.6165406145347],
  ["14007","El Corcovado - El Torreón","14007050","Localidad simple",-32.149759071844,-64.5015914694579],
  ["14007","El Durazno","14007055","Localidad simple",-32.1695656120551,-64.7747710529989],
  ["14007","Embalse","14007060","Localidad simple",-32.2065076875762,-64.4006226825819],
  ["14007","La Cruz","14007070","Localidad simple",-32.3034055718452,-64.4831089740344],
  ["14007","La Cumbrecita","14007080","Componente de localidad compuesta",-31.8969643877578,-64.7751589433588],
  ["14007","Las Bajadas","14007090","Localidad simple",-32.0954063583092,-64.3310535546374],
  ["14007","Las Caleras","14007100","Localidad simple",-32.3893612457104,-64.5185923418535],
  ["14007","Los Cóndores","14007110","Localidad simple",-32.3211277679392,-64.2810080327514],
  ["14007","Los Molinos","14007120","Localidad simple",-31.8568223164308,-64.3779521586489],
  ["14007","Los Reartes","14007130","Componente de localidad compuesta",-31.919856077953,-64.5755037073335],
  ["14007","Lutti","14007140","Localidad simple",-32.2989441032587,-64.7254379234594],
  ["14007","Parque Calmayo","14007160","Localidad simple",-32.0237443074993,-64.4641636844137],
  ["14007","Río de los Sauces","14007170","Localidad simple",-32.5265595269976,-64.586953080243],
  ["14007","San Agustín","14007180","Localidad simple",-31.9763155149128,-64.3733067164283],
  ["14007","San Ignacio (Loteo San Javier)","14007190","Localidad simple",-32.1667856733263,-64.516397206098],
  ["14007","Santa Rosa de Calamuchita","14007210","Localidad simple",-32.0700578177618,-64.537633731877],
  ["14007","Segunda Usina","14007220","Localidad simple",-32.1650425977053,-64.3784225873001],
  ["14007","Solar de los Molinos","14007230","Localidad simple",-31.8262216703829,-64.5197802668561],
  ["14007","Villa Alpina","14007240","Localidad simple",-31.9532611007669,-64.8132541353652],
  ["14007","Villa Amancay","14007250","Localidad simple",-32.1863928332037,-64.570452981186],
  ["14007","Villa Berna","14007260","Localidad simple",-31.9052382568314,-64.7428823583405],
  ["14007","Villa Ciudad Parque Los Reartes (1a. Sección)","14007270","Componente de localidad compuesta",-31.9118704947274,-64.5279613493097],
  ["14007","Villa del Dique","14007290","Componente de localidad compuesta",-32.1696837164743,-64.4567952849232],
  ["14007","Villa El Tala","14007300","Localidad simple",-32.2542673612565,-64.5850039184627],
  ["14007","Villa General Belgrano","14007310","Localidad simple",-31.9808236449718,-64.5606191505918],
  ["14007","Villa La Rivera","14007320","Localidad simple",-32.2667329359208,-64.5204928765462],
  ["14007","Villa Quillinzo","14007330","Localidad simple",-32.2384365356542,-64.5210498971139],
  ["14007","Villa Rumipal","14007340","Componente de localidad compuesta",-32.1893813417323,-64.4792063354191],
  ["14007","Villa Yacanto","14007360","Localidad simple",-32.1037825310006,-64.7541028295247],
  ["14014","Córdoba","14014010","Componente de localidad compuesta",-31.4138166206931,-64.1833384346292],
  ["14021","Agua de Oro","14021010","Componente de localidad compuesta",-31.058228127494,-64.2955793576311],
  ["14021","Ascochinga","14021020","Localidad simple",-30.9594645513035,-64.2754165610863],
  ["14021","Barrio Nuevo Río Ceballos","14021025","Componente de localidad compuesta",-31.1980230004722,-64.2887924252948],
  ["14021","Canteras El Sauce","14021030","Componente de localidad compuesta",-31.0864140054075,-64.3145341004157],
  ["14021","Casa Bamba","14021040","Localidad simple",-31.3429017095306,-64.3992718801552],
  ["14021","Colonia Caroya","14021050","Localidad simple",-31.0172322466264,-64.066728610829],
  ["14021","Colonia Tirolesa","14021060","Localidad simple",-31.2357859283773,-64.0672541009396],
  ["14021","Colonia Vicente Agüero","14021070","Localidad simple",-31.0277849308523,-64.0190456537309],
  ["14021","Villa Corazón de María","14021075","Componente de localidad compuesta",-31.4435294401245,-63.9963793951592],
  ["14021","Corral Quemado","14021080","Localidad simple",-30.9890353478112,-64.3778448899044],
  ["14021","Country San Isidro - Country Chacras de la Villa","14021090","Localidad simple",-31.3015080091569,-64.2382229714889],
  ["14021","El Manzano","14021110","Componente de localidad compuesta",-31.0817617139175,-64.2998324164847],
  ["14021","Estación Colonia Tirolesa","14021120","Localidad simple",-31.2735550500587,-64.0150545730464],
  ["14021","General Paz","14021130","Localidad simple",-31.1341189126982,-64.1410056588479],
  ["14021","Jesús María","14021140","Localidad simple",-30.9811937384049,-64.0957712868729],
  ["14021","La Calera","14021150","Componente de localidad compuesta",-31.3441541784042,-64.3368093736089],
  ["14021","La Granja","14021160","Componente de localidad compuesta",-31.0054374122172,-64.2616783510445],
  ["14021","La Morada","14021165","Localidad simple",-31.3050726647191,-64.2625844071662],
  ["14021","La Puerta","14021170","Localidad simple",-31.1419300602666,-64.0402188172603],
  ["14021","Las Corzuelas","14021175","Componente de localidad compuesta",-31.240896079449,-64.2618872007094],
  ["14021","Los Molles","14021180","Localidad simple",-31.0167070305726,-64.2253880804829],
  ["14021","Malvinas Argentinas","14021190","Componente de localidad compuesta",-31.3677025435362,-64.0503196448495],
  ["14021","Mendiolaza","14021200","Componente de localidad compuesta",-31.2634679794013,-64.3038336466706],
  ["14021","Mi Granja","14021210","Localidad simple",-31.3501106609981,-63.9996450992295],
  ["14021","Pajas Blancas","14021220","Localidad simple",-31.2146356684786,-64.2768259906649],
  ["14021","Río Ceballos","14021230","Componente de localidad compuesta",-31.1748535571499,-64.3096761754849],
  ["14021","Saldán","14021240","Componente de localidad compuesta",-31.3142696814131,-64.3129043036137],
  ["14021","Salsipuedes","14021250","Componente de localidad compuesta",-31.1388344121698,-64.2906610433299],
  ["14021","Santa Elena","14021260","Localidad simple",-31.2593058004875,-64.0753189644633],
  ["14021","Tinoco","14021270","Localidad simple",-31.1238790204144,-63.8923777817114],
  ["14021","Unquillo","14021280","Componente de localidad compuesta",-31.2319725034056,-64.3177425598673],
  ["14021","Villa Allende","14021290","Componente de localidad compuesta",-31.2922067561376,-64.2950077746201],
  ["14021","Villa Cerro Azul","14021300","Localidad simple",-31.0702139869894,-64.3197333591217],
  ["14021","Parque Norte - Ciudad de los Niños - Villa Pastora - Almirante Brown - Guiñazú N","14021310","Componente de localidad compuesta",-31.3101307241869,-64.1805270805742],
  ["14021","Villa Los Llanos - Juárez Celman","14021320","Localidad simple",-31.2742571242585,-64.1641142793008],
  ["14028","Alto de los Quebrachos","14028010","Localidad simple",-30.5409658147192,-65.0384387721916],
  ["14028","Bañado de Soto","14028020","Localidad simple",-30.8044357869451,-65.0436620185917],
  ["14028","Canteras Quilpo","14028030","Localidad simple",-30.8666932853441,-64.6829010647536],
  ["14028","Cruz de Caña","14028040","Localidad simple",-31.0662466251544,-64.9425321672363],
  ["14028","Cruz del Eje","14028050","Localidad simple",-30.7218592173101,-64.8077377312137],
  ["14028","El Brete","14028060","Localidad simple",-30.6722100581192,-64.8699070292303],
  ["14028","El Rincón","14028070","Localidad simple",-30.7397207125925,-64.6484924752741],
  ["14028","Guanaco Muerto","14028080","Localidad simple",-30.4794131800612,-65.0597627738017],
  ["14028","La Banda","14028090","Localidad simple",-30.7628592235779,-64.6459839334075],
  ["14028","La Batea","14028100","Localidad simple",-30.4417646532675,-65.4238386532105],
  ["14028","La Higuera","14028110","Localidad simple",-31.0139548417914,-65.1020313666951],
  ["14028","Las Cañadas","14028120","Localidad simple",-30.9332479488458,-64.7189758691612],
  ["14028","Las Playas","14028130","Localidad simple",-30.6895900139602,-64.8508831281017],
  ["14028","Los Chañaritos","14028140","Componente de localidad compuesta",-30.5724823864554,-64.9410778222467],
  ["14028","Media Naranja","14028150","Localidad simple",-30.6233104657952,-64.9515406139404],
  ["14028","Paso Viejo","14028160","Localidad simple",-30.7686835768001,-65.1864700189142],
  ["14028","San Marcos Sierra","14028170","Localidad simple",-30.7803420622583,-64.6468515131076],
  ["14028","Serrezuela","14028180","Localidad simple",-30.6392026300348,-65.3813009621884],
  ["14028","Tuclame","14028190","Localidad simple",-30.7485284753417,-65.2375410689391],
  ["14028","Villa de Soto","14028200","Localidad simple",-30.852977256889,-64.9924997261449],
  ["14035","Del Campillo","14035010","Localidad simple",-34.3760847098309,-64.4945399243505],
  ["14035","Estación Lecueder","14035020","Localidad simple",-34.4964110409998,-64.8094621973322],
  ["14035","Hipólito Bouchard","14035030","Localidad simple",-34.7223142041085,-63.508013061936],
  ["14035","Huinca Renancó","14035040","Localidad simple",-34.8397251237332,-64.3724876795015],
  ["14035","Italó","14035050","Localidad simple",-34.7911820710534,-63.781208388865],
  ["14035","Mattaldi","14035060","Localidad simple",-34.4803867338234,-64.1695033049234],
  ["14035","Nicolás Bruzzone","14035070","Localidad simple",-34.4382295005707,-64.3383707319069],
  ["14035","Onagoity","14035080","Localidad simple",-34.7703021224105,-63.67032307176],
  ["14035","Pincén","14035090","Localidad simple",-34.8379291437488,-63.9155804696192],
  ["14035","Ranqueles","14035100","Localidad simple",-34.8436937843761,-64.0987740916452],
  ["14035","Santa Magdalena","14035110","Localidad simple",-34.514736598064,-63.941510935076],
  ["14035","Villa Huidobro","14035120","Localidad simple",-34.8371817717375,-64.5833571665395],
  ["14035","Villa Sarmiento","14035130","Localidad simple",-34.1216195744231,-64.7240499364673],
  ["14035","Villa Valeria","14035140","Localidad simple",-34.3408530354994,-64.917844943457],
  ["14042","Arroyo Algodón","14042010","Localidad simple",-32.2019665986816,-63.1627861860009],
  ["14042","Arroyo Cabral","14042020","Localidad simple",-32.4889824965456,-63.4014794487713],
  ["14042","Ausonia","14042030","Localidad simple",-32.6613825801545,-63.2447973807791],
  ["14042","Chazón","14042040","Localidad simple",-33.0772598274988,-63.275435286184],
  ["14042","Etruria","14042050","Localidad simple",-32.9405157092885,-63.2472565146999],
  ["14042","La Laguna","14042060","Localidad simple",-32.8014149822474,-63.2440045658431],
  ["14042","La Palestina","14042070","Localidad simple",-32.6155884790713,-63.4092352057166],
  ["14042","La Playosa","14042080","Localidad simple",-32.0996948600789,-63.0325289648087],
  ["14042","Las Mojarras","14042090","Localidad simple",-32.3029687109385,-63.2328555816575],
  ["14042","Luca","14042100","Localidad simple",-32.5401979602741,-63.4762536378135],
  ["14042","Pasco","14042110","Localidad simple",-32.7470044961114,-63.3411254262064],
  ["14042","Sanabria","14042120","Localidad simple",-32.527560043626,-63.2479616144958],
  ["14042","Silvio Pellico","14042130","Localidad simple",-32.2506338091324,-62.931650118919],
  ["14042","Ticino","14042140","Localidad simple",-32.6919271380136,-63.4353044375428],
  ["14042","Tío Pujio","14042150","Localidad simple",-32.2863739057236,-63.3540179546817],
  ["14042","Villa Albertina","14042160","Localidad simple",-32.4342175966013,-63.1844586471364],
  ["14042","Villa María","14042170","Componente de localidad compuesta",-32.4120836110321,-63.2499951238659],
  ["14042","Villa Nueva","14042180","Componente de localidad compuesta",-32.4288251783807,-63.249359249877],
  ["14042","Villa Oeste","14042190","Localidad simple",-32.4343319670367,-63.2875591644345],
  ["14049","Avellaneda","14049010","Localidad simple",-30.5946762022718,-64.2078393373412],
  ["14049","Cañada de Río Pinto","14049020","Localidad simple",-30.7759183214925,-64.2182971976614],
  ["14049","Chuña","14049030","Localidad simple",-30.4687274606224,-64.6712287665168],
  ["14049","Copacabana","14049040","Localidad simple",-30.6113486219317,-64.5555688574614],
  ["14049","Deán Funes","14049050","Localidad simple",-30.4229409365773,-64.3516697664768],
  ["14049","Esquina del Alambre","14049060","Localidad simple",-30.6016118281727,-64.9074033309966],
  ["14049","Los Pozos","14049080","Localidad simple",-30.5154516695053,-64.2664449882016],
  ["14049","Olivares de San Nicolás","14049090","Localidad simple",-30.6020503748658,-64.8433653744314],
  ["14049","Quilino","14049100","Localidad simple",-30.2159552214688,-64.5029777045333],
  ["14049","San Pedro de Toyos","14049110","Localidad simple",-30.4541583004868,-64.4475688737826],
  ["14049","Villa Gutiérrez","14049120","Localidad simple",-30.6569511707803,-64.1819590809899],
  ["14049","Villa Quilino","14049130","Localidad simple",-30.2101157475483,-64.4775674155262],
  ["14056","Alejandro Roca","14056010","Localidad simple",-33.3564514451723,-63.7205503922441],
  ["14056","Assunta","14056020","Localidad simple",-33.6332962011646,-63.2259060913547],
  ["14056","Bengolea","14056030","Localidad simple",-33.0274173144801,-63.6719277875696],
  ["14056","Carnerillo","14056040","Localidad simple",-32.9153142058652,-64.0256580552867],
  ["14056","Charras","14056050","Localidad simple",-33.0241677315378,-64.0458262411649],
  ["14056","El Rastreador","14056060","Localidad simple",-33.6644787319553,-63.5392368036406],
  ["14056","General Cabrera","14056070","Localidad simple",-32.8118910840567,-63.8736965709555],
  ["14056","General Deheza","14056080","Localidad simple",-32.7549291159098,-63.7850383518255],
  ["14056","Huanchillas","14056090","Localidad simple",-33.6655227252595,-63.6372618363763],
  ["14056","La Carlota","14056100","Localidad simple",-33.4201679372505,-63.2969802619056],
  ["14056","Los Cisnes","14056110","Localidad simple",-33.400060095449,-63.4716515559202],
  ["14056","Olaeta","14056120","Localidad simple",-33.0434821211836,-63.9085957407616],
  ["14056","Pacheco de Melo","14056130","Localidad simple",-33.7600575092431,-63.4898589767857],
  ["14056","Paso del Durazno","14056140","Componente de localidad compuesta",-33.1704554487519,-64.0478670082552],
  ["14056","Santa Eufemia","14056150","Localidad simple",-33.1767529632621,-63.2820358699256],
  ["14056","Ucacha","14056160","Localidad simple",-33.0334392795816,-63.5082571588932],
  ["14056","Villa Reducción","14056170","Localidad simple",-33.2014556304775,-63.8622207209792],
  ["14063","Alejo Ledesma","14063010","Localidad simple",-33.6076125942499,-62.6261405718946],
  ["14063","Arias","14063020","Localidad simple",-33.6411632781096,-62.402789011452],
  ["14063","Camilo Aldao","14063030","Localidad simple",-33.123740825534,-62.0965954602144],
  ["14063","Capitán General Bernardo O'Higgins","14063040","Localidad simple",-33.247202805036,-62.269738358968],
  ["14063","Cavanagh","14063050","Localidad simple",-33.4783348989439,-62.3393464555145],
  ["14063","Colonia Barge","14063060","Localidad simple",-33.2585411549016,-62.6081628269792],
  ["14063","Colonia Italiana","14063070","Localidad simple",-33.3119180942558,-62.1807987939012],
  ["14063","Colonia Veinticinco","14063080","Localidad simple",-32.8883679292315,-61.9347825911775],
  ["14063","Corral de Bustos","14063090","Localidad simple",-33.2816219895104,-62.1854508942409],
  ["14063","Cruz Alta","14063100","Localidad simple",-33.0069947278727,-61.8109726038419],
  ["14063","General Baldissera","14063110","Localidad simple",-33.1220171765357,-62.3037212558104],
  ["14063","General Roca","14063120","Localidad simple",-32.7305115296671,-61.917138712509],
  ["14063","Guatimozín","14063130","Localidad simple",-33.4617411292085,-62.4391434502619],
  ["14063","Inriville","14063140","Localidad simple",-32.9438405235327,-62.2305487525417],
  ["14063","Isla Verde","14063150","Localidad simple",-33.2401071501959,-62.404426547367],
  ["14063","Leones","14063160","Localidad simple",-32.658391411409,-62.299914625293],
  ["14063","Los Surgentes","14063170","Localidad simple",-32.9843826304567,-62.0237039883188],
  ["14063","Marcos Juárez","14063180","Localidad simple",-32.6913099811557,-62.1057946726991],
  ["14063","Monte Buey","14063190","Localidad simple",-32.9175280341379,-62.4576576002351],
  ["14063","Saira","14063210","Localidad simple",-32.4064116368009,-62.1029831790036],
  ["14063","Saladillo","14063220","Localidad simple",-32.9331604883654,-62.3428774336317],
  ["14063","Villa Elisa","14063230","Localidad simple",-32.7487775757302,-62.3306744044274],
  ["14070","Ciénaga del Coro","14070010","Localidad simple",-31.0381142705456,-65.2775888503175],
  ["14070","El Chacho","14070020","Localidad simple",-30.8017974058313,-65.6440521440398],
  ["14070","Estancia de Guadalupe","14070030","Localidad simple",-31.1242101609074,-65.2269002056273],
  ["14070","Guasapampa","14070040","Localidad simple",-31.0975357099584,-65.3281875063158],
  ["14070","La Playa","14070050","Localidad simple",-31.0350257440514,-65.3453122247049],
  ["14070","San Carlos Minas","14070060","Localidad simple",-31.175590415787,-65.101705426717],
  ["14070","Talaini","14070070","Localidad simple",-31.2496924733149,-65.1672000423356],
  ["14070","Tosno","14070080","Localidad simple",-30.9499425576932,-65.3099277411768],
  ["14077","Chancani","14077010","Localidad simple",-31.4172820195639,-65.4453421341012],
  ["14077","Las Palmas","14077020","Localidad simple",-31.3800076236386,-65.2899757237495],
  ["14077","Los Talares","14077030","Localidad simple",-31.3754115021879,-65.0386011461093],
  ["14077","Salsacate","14077040","Localidad simple",-31.3151616749444,-65.0910260595287],
  ["14077","San Gerónimo","14077050","Localidad simple",-31.3409519996631,-64.9131949666644],
  ["14077","Tala Cañada","14077060","Localidad simple",-31.3570289681593,-64.9764519289304],
  ["14077","Taninga","14077070","Localidad simple",-31.3454000529726,-65.0801168738369],
  ["14077","Villa de Pocho","14077080","Localidad simple",-31.4880894840309,-65.2830353856188],
  ["14084","General Levalle","14084010","Localidad simple",-34.0098324798955,-63.9225367502507],
  ["14084","La Cesira","14084020","Localidad simple",-33.9518611160055,-62.9744894136507],
  ["14084","Laboulaye","14084030","Localidad simple",-34.1236122063832,-63.388646306069],
  ["14084","Leguizamón","14084040","Localidad simple",-34.2040788458157,-62.9768889543713],
  ["14084","Melo","14084050","Localidad simple",-34.3483191246017,-63.4471714447308],
  ["14084","Río Bamba","14084060","Localidad simple",-34.0511211181075,-63.7321532881296],
  ["14084","Rosales","14084070","Localidad simple",-34.171790725852,-63.1534798469172],
  ["14084","San Joaquín","14084080","Localidad simple",-34.5106395562101,-63.7132746964365],
  ["14084","Serrano","14084090","Localidad simple",-34.4699818959404,-63.5375595280643],
  ["14084","Villa Rossi","14084100","Localidad simple",-34.297937327836,-63.2685397142969],
  ["14091","Barrio Santa Isabel","14091010","Localidad simple",-30.8375267087623,-64.5367004570805],
  ["14091","Bialet Massé","14091020","Componente de localidad compuesta",-31.3123081567618,-64.4629696370027],
  ["14091","Cabalango","14091030","Localidad simple",-31.3931049014855,-64.5635652642982],
  ["14091","Capilla del Monte","14091040","Localidad simple",-30.8563966713395,-64.526268881497],
  ["14091","Casa Grande","14091050","Componente de localidad compuesta",-31.1697129911083,-64.4776214321437],
  ["14091","Charbonier","14091060","Localidad simple",-30.7720869099195,-64.5441595530858],
  ["14091","Cosquín","14091070","Componente de localidad compuesta",-31.240571224569,-64.4655312574209],
  ["14091","Cuesta Blanca","14091080","Componente de localidad compuesta",-31.4787781890782,-64.5773466914484],
  ["14091","Estancia Vieja","14091090","Componente de localidad compuesta",-31.3842597063571,-64.517330819559],
  ["14091","Huerta Grande","14091100","Componente de localidad compuesta",-31.0600927199176,-64.484304266589],
  ["14091","La Cumbre","14091110","Componente de localidad compuesta",-30.9792461523826,-64.4909087135044],
  ["14091","La Falda","14091120","Componente de localidad compuesta",-31.0919649906581,-64.4864417754561],
  ["14091","Las Jarillas","14091130","Localidad simple",-31.5182256602189,-64.5345928843012],
  ["14091","Los Cocos","14091140","Componente de localidad compuesta",-30.9269774865861,-64.5026123921003],
  ["14091","Mallín","14091150","Localidad simple",-31.2976747453985,-64.5749813483232],
  ["14091","Mayu Sumaj","14091160","Componente de localidad compuesta",-31.4668646402709,-64.5427634762868],
  ["14091","Quebrada de Luna","14091170","Localidad simple",-30.7949898871398,-64.5210978856737],
  ["14091","San Antonio de Arredondo","14091180","Componente de localidad compuesta",-31.4782264688487,-64.5289350434399],
  ["14091","San Esteban","14091190","Componente de localidad compuesta",-30.9199784063317,-64.5360036651851],
  ["14091","San Roque","14091200","Componente de localidad compuesta",-31.3496904364626,-64.4599293921174],
  ["14091","Santa María de Punilla","14091210","Componente de localidad compuesta",-31.2703319860361,-64.4653357678432],
  ["14091","Tala Huasi","14091220","Componente de localidad compuesta",-31.472446933222,-64.5651507693433],
  ["14091","Tanti","14091230","Componente de localidad compuesta",-31.3549072437345,-64.5909558305817],
  ["14091","Valle Hermoso","14091240","Componente de localidad compuesta",-31.1172888298585,-64.484252831532],
  ["14091","Villa Carlos Paz","14091250","Componente de localidad compuesta",-31.4182380208919,-64.4933448063141],
  ["14091","Villa Flor Serrana","14091260","Localidad simple",-31.3864690388309,-64.6003659348122],
  ["14091","Villa Giardino","14091270","Componente de localidad compuesta",-31.0362773938945,-64.4928899121054],
  ["14091","Villa Lago Azul","14091280","Localidad simple",-31.3740257221359,-64.4831122938584],
  ["14091","Villa Parque Siquimán","14091290","Componente de localidad compuesta",-31.3457170881093,-64.4802571053108],
  ["14091","Villa Río Icho Cruz","14091300","Componente de localidad compuesta",-31.4791065590312,-64.562747406585],
  ["14091","Villa San José","14091310","Localidad simple",-31.279612799499,-64.5653436907589],
  ["14091","Villa Santa Cruz del Lago","14091320","Componente de localidad compuesta",-31.369322851246,-64.5205370832482],
  ["14098","Achiras","14098010","Localidad simple",-33.1770175916926,-64.9944684969757],
  ["14098","Adelia María","14098020","Localidad simple",-33.631620222358,-64.0208372956378],
  ["14098","Alcira Gigena","14098030","Localidad simple",-32.757065291399,-64.3378599293347],
  ["14098","Alpa Corral","14098040","Localidad simple",-32.6904036665231,-64.721171054893],
  ["14098","Berrotarán","14098050","Localidad simple",-32.4528669215341,-64.3854404675021],
  ["14098","Bulnes","14098060","Localidad simple",-33.5032818212674,-64.6755735163666],
  ["14098","Chaján","14098070","Localidad simple",-33.5563361347485,-65.0052699166312],
  ["14098","Chucul","14098080","Localidad simple",-33.0089546768665,-64.1712493406755],
  ["14098","Coronel Baigorria","14098090","Localidad simple",-32.8495478948519,-64.3598591374051],
  ["14098","Coronel Moldes","14098100","Localidad simple",-33.6230868735031,-64.5971033510391],
  ["14098","Elena","14098110","Localidad simple",-32.5720684109952,-64.3929518423935],
  ["14098","La Carolina","14098120","Localidad simple",-33.1868433713045,-64.7251129655857],
  ["14098","La Cautiva","14098130","Localidad simple",-33.97859138783,-64.0842989461185],
  ["14098","La Gilda","14098140","Localidad simple",-33.2082959166527,-64.2584448995097],
  ["14098","Las Acequias","14098150","Localidad simple",-33.2822486969948,-63.9758763865889],
  ["14098","Las Albahacas","14098160","Localidad simple",-32.8924933762193,-64.8435915248655],
  ["14098","Las Higueras","14098170","Componente de localidad compuesta",-33.0892422210206,-64.2868227686532],
  ["14098","Las Peñas","14098180","Localidad simple",-32.5348511864127,-64.1052291964295],
  ["14098","Las Vertientes","14098190","Localidad simple",-33.283946385224,-64.5781462257606],
  ["14098","Malena","14098200","Localidad simple",-33.4893410861497,-64.4320008051115],
  ["14098","Monte de los Gauchos","14098210","Localidad simple",-33.636887956776,-63.8900068799972],
  ["14098","Paso del Durazno","14098220","Componente de localidad compuesta",-33.170068435327,-64.0496307678069],
  ["14098","Río Cuarto","14098230","Componente de localidad compuesta",-33.1242631220063,-64.3487377033754],
  ["14098","Sampacho","14098240","Localidad simple",-33.3845382952352,-64.7219849539761],
  ["14098","San Basilio","14098250","Localidad simple",-33.4978542515605,-64.3151828240087],
  ["14098","Santa Catalina Holmberg","14098260","Localidad simple",-33.2059384521037,-64.4348164483493],
  ["14098","Suco","14098270","Localidad simple",-33.4394729739475,-64.8316610855999],
  ["14098","Tosquitas","14098280","Localidad simple",-33.8188248224493,-64.4569327410668],
  ["14098","Vicuña Mackenna","14098290","Localidad simple",-33.917235746816,-64.3902222715013],
  ["14098","Villa El Chacay","14098300","Localidad simple",-32.893726660666,-64.8675140784316],
  ["14098","Villa Santa Eugenia","14098310","Localidad simple",-32.6651066386532,-64.741501810378],
  ["14098","Washington","14098320","Localidad simple",-33.8733676407196,-64.6886182213475],
  ["14105","Atahona","14105010","Localidad simple",-30.9035316228673,-63.7055651181425],
  ["14105","Cañada de Machado","14105020","Localidad simple",-31.4289242714312,-63.5870264507761],
  ["14105","Capilla de los Remedios","14105030","Localidad simple",-31.4302065756542,-63.8321496909141],
  ["14105","Chalacea","14105040","Localidad simple",-30.7545707267715,-63.5682265940855],
  ["14105","Colonia Las Cuatro Esquinas","14105050","Localidad simple",-31.1735851610445,-63.3375921895432],
  ["14105","Diego de Rojas","14105060","Localidad simple",-31.0286404171341,-63.3402795519709],
  ["14105","El Alcalde","14105070","Localidad simple",-31.1161396833417,-63.6017410478522],
  ["14105","El Crispín","14105080","Localidad simple",-31.017971601362,-63.6051650588702],
  ["14105","Esquina","14105090","Localidad simple",-31.0772911263196,-63.7935627786301],
  ["14105","Kilómetro 658","14105100","Localidad simple",-31.3701809412977,-63.5326025508152],
  ["14105","La Para","14105110","Localidad simple",-30.8925359716793,-63.0010662681494],
  ["14105","La Posta","14105120","Localidad simple",-30.5653596004713,-63.5163053686029],
  ["14105","La Puerta","14105130","Localidad simple",-30.8926051154777,-63.2532712015226],
  ["14105","La Quinta","14105140","Localidad simple",-31.0622588456023,-63.1501281830965],
  ["14105","Las Gramillas","14105150","Localidad simple",-31.0882555128663,-63.2418444621471],
  ["14105","Las Saladas","14105160","Localidad simple",-30.7594681012857,-63.2035027286925],
  ["14105","Maquinista Gallini","14105170","Localidad simple",-30.9074419738178,-63.532118614378],
  ["14105","Monte del Rosario","14105180","Localidad simple",-30.9826026339688,-63.6017850424963],
  ["14105","Montecristo","14105190","Localidad simple",-31.3438538707604,-63.9457735584091],
  ["14105","Obispo Trejo","14105200","Localidad simple",-30.7811924488334,-63.4130494343907],
  ["14105","Piquillín","14105210","Localidad simple",-31.2995844445842,-63.7591050718367],
  ["14105","Plaza de Mercedes","14105220","Localidad simple",-30.9780514540426,-63.2596192028417],
  ["14105","Pueblo Comechingones","14105230","Localidad simple",-31.1685485898925,-63.6075820921855],
  ["14105","Río Primero","14105240","Localidad simple",-31.3291838493003,-63.621866727412],
  ["14105","Sagrada Familia","14105250","Localidad simple",-31.2897282303946,-63.445471703469],
  ["14105","Santa Rosa de Río Primero","14105260","Localidad simple",-31.1514772066717,-63.4015912555355],
  ["14105","Villa Fontana","14105270","Localidad simple",-30.8940088267342,-63.1159181990178],
  ["14112","Cerro Colorado","14112010","Componente de localidad compuesta",-30.0960599330651,-63.9287731727735],
  ["14112","Chañar Viejo","14112020","Localidad simple",-30.0139606979962,-63.8503752152119],
  ["14112","Eufrasio Loza","14112030","Localidad simple",-29.9247226351086,-63.5889152129175],
  ["14112","Gütemberg","14112040","Localidad simple",-29.7227092489555,-63.5149951918634],
  ["14112","La Rinconada","14112050","Localidad simple",-30.1846537889428,-62.8301426342643],
  ["14112","Los Hoyos","14112060","Localidad simple",-29.802434071812,-63.6273622842683],
  ["14112","Puesto de Castro","14112070","Localidad simple",-30.2390823848323,-63.4916854103812],
  ["14112","Rayo Cortado","14112080","Localidad simple",-30.0742593288829,-63.8249818238142],
  ["14112","San Pedro de Gütemberg","14112090","Localidad simple",-29.698228417088,-63.5610809474438],
  ["14112","Santa Elena","14112100","Localidad simple",-30.1174756551011,-63.8438054710488],
  ["14112","Sebastián Elcano","14112110","Localidad simple",-30.1614462636479,-63.5934503863753],
  ["14112","Villa Candelaria","14112120","Localidad simple",-29.8162963199276,-63.3548391354924],
  ["14112","Villa de María","14112130","Localidad simple",-29.9043583402484,-63.722318985926],
  ["14119","Calchín","14119010","Localidad simple",-31.6679359912419,-63.2006870937546],
  ["14119","Calchín Oeste","14119020","Localidad simple",-31.8633868408967,-63.278168375262],
  ["14119","Capilla del Carmen","14119030","Localidad simple",-31.5081678166164,-63.3421354529106],
  ["14119","Carrilobo","14119040","Localidad simple",-31.8716468802323,-63.1165074420857],
  ["14119","Colazo","14119050","Localidad simple",-31.964293093898,-63.3834011052136],
  ["14119","Colonia Videla","14119060","Localidad simple",-31.9175044736895,-63.5047159461534],
  ["14119","Costasacate","14119070","Localidad simple",-31.6470984739179,-63.7598955842162],
  ["14119","Impira","14119080","Localidad simple",-31.7965929244084,-63.6511207667299],
  ["14119","Laguna Larga","14119090","Localidad simple",-31.7783987221778,-63.8027369015332],
  ["14119","Las Junturas","14119100","Localidad simple",-31.8313972998615,-63.4506364545889],
  ["14119","Los Chañaritos","14119110","Localidad simple",-31.4021377541587,-63.3321030427196],
  ["14119","Luque","14119120","Localidad simple",-31.6468736294787,-63.344798299585],
  ["14119","Manfredi","14119130","Localidad simple",-31.8440585633394,-63.7460746070431],
  ["14119","Matorrales","14119140","Localidad simple",-31.7144720415401,-63.5118521462998],
  ["14119","Oncativo","14119150","Localidad simple",-31.912835805369,-63.6836820317482],
  ["14119","Pilar","14119160","Componente de localidad compuesta",-31.6804516863719,-63.8814979795567],
  ["14119","Pozo del Molle","14119170","Localidad simple",-32.0194389864602,-62.9199182599484],
  ["14119","Rincón","14119180","Localidad simple",-31.595385474428,-63.6155414282074],
  ["14119","Río Segundo","14119190","Componente de localidad compuesta",-31.650153972407,-63.9118630162229],
  ["14119","Santiago Temple","14119200","Localidad simple",-31.3871253007234,-63.4182078006181],
  ["14119","Villa del Rosario","14119210","Localidad simple",-31.5540113344661,-63.5341489014562],
  ["14126","Ambul","14126010","Localidad simple",-31.489683021508,-65.0566540377037],
  ["14126","Arroyo Los Patos","14126020","Localidad simple",-31.7500816583302,-65.0043001880149],
  ["14126","El Huayco","14126030","Localidad simple",-31.845848320458,-64.956092175607],
  ["14126","La Cortadera","14126040","Localidad simple",-31.668668399569,-65.37239422356],
  ["14126","Las Calles","14126050","Localidad simple",-31.8206855464004,-64.9717608825205],
  ["14126","Las Oscuras","14126060","Localidad simple",-31.6633718662216,-65.3190950145101],
  ["14126","Las Rabonas","14126070","Localidad simple",-31.8544494669466,-64.9870970596913],
  ["14126","Los Callejones","14126080","Localidad simple",-31.9322689128265,-65.2330653421552],
  ["14126","Mina Clavero","14126090","Componente de localidad compuesta",-31.7267843574618,-65.0055332639058],
  ["14126","Mussi","14126100","Localidad simple",-31.4273241562001,-65.0756894821312],
  ["14126","Nono","14126110","Localidad simple",-31.795570031823,-65.0034036260171],
  ["14126","Panaholma","14126120","Localidad simple",-31.626892878253,-65.058665894714],
  ["14126","San Huberto","14126130","Localidad simple",-31.8325293805629,-64.9856729137672],
  ["14126","San Lorenzo","14126140","Localidad simple",-31.6822276756771,-65.0255685400222],
  ["14126","San Martín","14126150","Localidad simple",-31.8969863219692,-65.5246625976025],
  ["14126","San Pedro","14126160","Componente de localidad compuesta",-31.9368244076607,-65.2192402223011],
  ["14126","San Vicente","14126170","Localidad simple",-31.8549846523947,-65.4304499825782],
  ["14126","Sauce Arriba","14126180","Localidad simple",-31.9143833881487,-65.1687928322254],
  ["14126","Tasna","14126190","Localidad simple",-31.6303406921333,-65.1483381584252],
  ["14126","Villa Cura Brochero","14126200","Componente de localidad compuesta",-31.7063690825109,-65.0191109777329],
  ["14126","Villa Sarmiento","14126210","Componente de localidad compuesta",-31.9366572471396,-65.191796702404],
  ["14133","Conlara","14133010","Localidad simple",-32.0788609958394,-65.2312586416728],
  ["14133","Cruz Caña","14133030","Localidad simple",-32.2779029026255,-65.0273777504727],
  ["14133","Dos Arroyos","14133040","Localidad simple",-31.8716867538421,-64.9927496394469],
  ["14133","El Pantanillo","14133050","Localidad simple",-31.8862653496977,-64.990651569992],
  ["14133","La Paz","14133060","Localidad simple",-32.2172752387548,-65.0511157108408],
  ["14133","La Población","14133070","Localidad simple",-32.0660031804969,-65.0309086009182],
  ["14133","La Ramada","14133080","Localidad simple",-32.2996521283095,-65.0361512187387],
  ["14133","La Travesía","14133090","Localidad simple",-32.1066758248055,-65.063758957899],
  ["14133","Las Chacras","14133095","Localidad simple",-32.2418447787663,-65.0340964238205],
  ["14133","Las Tapias","14133100","Componente de localidad compuesta",-31.9522279195169,-65.1014219744873],
  ["14133","Loma Bola","14133105","Localidad simple",-32.2189295558758,-65.0285126897578],
  ["14133","Los Cerrillos","14133110","Localidad simple",-31.9737899960038,-65.4376442516279],
  ["14133","Los Hornillos","14133120","Localidad simple",-31.9017353099654,-64.9900890034518],
  ["14133","Los Molles","14133130","Localidad simple",-31.9620954005051,-65.0383138664304],
  ["14133","Luyaba","14133150","Localidad simple",-32.1483422464594,-65.056618698571],
  ["14133","Quebracho Ladeado","14133155","Localidad simple",-32.2570957550243,-65.0309211927709],
  ["14133","Quebrada de los Pozos","14133160","Localidad simple",-31.9074953420069,-65.0344580207268],
  ["14133","San Javier y Yacanto","14133170","Localidad simple",-32.0266518585481,-65.027552227227],
  ["14133","San José","14133180","Localidad simple",-31.9573259005881,-65.3152083482463],
  ["14133","Villa de las Rosas","14133190","Componente de localidad compuesta",-31.9484733205417,-65.0550181621034],
  ["14133","Villa Dolores","14133200","Componente de localidad compuesta",-31.9440434116077,-65.1961395608591],
  ["14133","Villa La Viña","14133210","Localidad simple",-31.872771150983,-65.0372746344972],
  ["14140","Alicia","14140010","Localidad simple",-31.9387491680744,-62.4657945680095],
  ["06063","San Agustín","06063050","Localidad simple",-38.0122838564587,-58.355377761682],
  ["14140","Altos de Chipión","14140020","Localidad simple",-30.9563507625723,-62.3378881220879],
  ["14140","Arroyito","14140030","Localidad simple",-31.4193908735633,-63.0503444103203],
  ["14140","Balnearia","14140040","Localidad simple",-31.0107075696974,-62.6671044005114],
  ["14140","Brinkmann","14140050","Localidad simple",-30.8665250177702,-62.0356522438995],
  ["14140","Colonia Anita","14140060","Localidad simple",-31.1438629464364,-62.2135862922774],
  ["14140","Colonia 10 de Julio","14140070","Localidad simple",-30.5273759974763,-62.114218229406],
  ["14140","Colonia Las Pichanas","14140080","Localidad simple",-31.2454066292386,-62.9256664887207],
  ["14140","Colonia Marina","14140090","Localidad simple",-31.2485066335845,-62.3639645596989],
  ["14140","Colonia Prosperidad","14140100","Localidad simple",-31.6304966252155,-62.3663613505205],
  ["14140","Colonia San Bartolomé","14140110","Localidad simple",-31.528322298444,-62.7244933856141],
  ["14140","Colonia San Pedro","14140120","Localidad simple",-30.7836021597954,-61.9175643185455],
  ["14140","Colonia Santa María","14140130","Localidad simple",-31.6057747904501,-62.4278882105043],
  ["14140","Colonia Valtelina","14140140","Localidad simple",-31.0529548297979,-62.235437860737],
  ["14140","Colonia Vignaud","14140150","Localidad simple",-30.8416242298498,-61.9558386203663],
  ["14140","Devoto","14140160","Localidad simple",-31.403980918137,-62.3061393858823],
  ["14140","El Arañado","14140170","Localidad simple",-31.7412330671687,-62.8933443705701],
  ["14140","El Fortín","14140180","Localidad simple",-31.9672502352148,-62.3026285942111],
  ["14140","El Fuertecito","14140190","Localidad simple",-31.4039349300198,-62.9733657676524],
  ["14140","El Tío","14140200","Localidad simple",-31.3845486215618,-62.82847376469],
  ["14140","Estación Luxardo","14140210","Localidad simple",-31.3047488843392,-62.1333023360613],
  ["14140","Colonia Iturraspe","14140215","Localidad simple",-31.2071433242951,-62.1099182033011],
  ["14140","Freyre","14140220","Localidad simple",-31.1647319320813,-62.0976333908888],
  ["14140","La Francia","14140230","Localidad simple",-31.406437919327,-62.634358101089],
  ["14140","La Paquita","14140240","Localidad simple",-30.9070545771133,-62.2154361817056],
  ["14140","La Tordilla","14140250","Localidad simple",-31.2352452196552,-63.0599042713798],
  ["14140","Las Varas","14140260","Localidad simple",-31.801292158779,-62.6171047243489],
  ["14140","Las Varillas","14140270","Localidad simple",-31.8731135581313,-62.7187948274612],
  ["14140","Marull","14140280","Localidad simple",-30.9945226321227,-62.8258401081139],
  ["14140","Miramar","14140290","Localidad simple",-30.9145163516027,-62.6749183796469],
  ["14140","Morteros","14140300","Localidad simple",-30.7107058083835,-62.0044437379159],
  ["14140","Plaza Luxardo","14140310","Localidad simple",-31.301747140591,-62.2291672872465],
  ["14140","Plaza San Francisco","14140320","Localidad simple",-31.3698057980989,-62.0980386090508],
  ["14140","Porteña","14140330","Localidad simple",-31.0139211475279,-62.0633288002735],
  ["14140","Quebracho Herrado","14140340","Localidad simple",-31.5496022220547,-62.2257312576183],
  ["14140","Sacanta","14140350","Localidad simple",-31.6633035739729,-63.0453212093259],
  ["14140","San Francisco","14140360","Localidad simple",-31.4276088869788,-62.0866336146078],
  ["14140","Saturnino María Laspiur","14140370","Localidad simple",-31.7029319509565,-62.4840180855351],
  ["14140","Seeber","14140380","Localidad simple",-30.9239726451413,-61.9737374276269],
  ["14140","Toro Pujio","14140390","Localidad simple",-31.1090401829574,-62.9876506224993],
  ["14140","Tránsito","14140400","Localidad simple",-31.4251109532295,-63.1954038579264],
  ["14140","Villa Concepción del Tío","14140420","Localidad simple",-31.3224689015774,-62.8144745758859],
  ["14140","Villa del Tránsito","14140430","Localidad simple",-31.4474037687006,-63.1940139744668],
  ["14140","Villa San Esteban","14140440","Localidad simple",-31.6335474004986,-62.896766816574],
  ["14147","Alta Gracia","14147010","Localidad simple",-31.6576798267691,-64.4288214061936],
  ["14147","Anisacate","14147020","Componente de localidad compuesta",-31.7231378713901,-64.4144863418681],
  ["14147","Barrio Gilbert (1º de Mayo) - Tejas Tres","14147030","Localidad simple",-31.4426508165936,-64.3178623084579],
  ["14147","Bouwer","14147050","Localidad simple",-31.557666956067,-64.1944658448779],
  ["14147","Campos del Virrey","14147055","Localidad simple",-31.5854354142153,-64.3439770074277],
  ["14147","Caseros Centro","14147060","Localidad simple",-31.52925614862,-64.1688666057858],
  ["14147","Causana","14147065","Localidad simple",-31.4637911559576,-64.4124514041777],
  ["14147","Costa Azul","14147070","Localidad simple",-31.7247289371172,-64.3939272186065],
  ["14147","Despeñaderos","14147080","Localidad simple",-31.8170515932731,-64.2889894059973],
  ["14147","Dique Chico","14147090","Localidad simple",-31.751852051978,-64.3627643049016],
  ["14147","El Potrerillo","14147095","Localidad simple",-31.6456181955204,-64.481617153406],
  ["14147","Falda del Cañete","14147100","Localidad simple",-31.5345237877237,-64.4559553621678],
  ["14147","Falda del Carmen","14147110","Localidad simple",-31.5854632680747,-64.4548814536225],
  ["14147","José de la Quintana","14147115","Localidad simple",-31.8034930461757,-64.418856525597],
  ["14147","La Boca del Río","14147120","Localidad simple",-31.8374172963205,-64.4336411746815],
  ["14147","La Carbonada","14147130","Localidad simple",-31.5285694623422,-64.0712556356294],
  ["14147","La Paisanita","14147150","Localidad simple",-31.7194206060413,-64.4779150030479],
  ["14147","La Perla","14147160","Localidad simple",-31.4425579240341,-64.3484859265831],
  ["14147","La Rancherita y Las Cascadas","14147170","Componente de localidad compuesta",-31.7574675409558,-64.4486902777249],
  ["14147","La Serranita","14147180","Componente de localidad compuesta",-31.7331340814564,-64.4564154524522],
  ["14147","Los Cedros","14147190","Localidad simple",-31.5262509877113,-64.2847584167114],
  ["14147","Lozada","14147200","Localidad simple",-31.6484545317081,-64.0899796115028],
  ["14147","Malagueño","14147210","Localidad simple",-31.4648051043666,-64.3584261973277],
  ["14147","Milenica","14147217","Localidad simple",-31.4572735024583,-64.4057106148379],
  ["14147","Monte Ralo","14147220","Componente de localidad compuesta",-31.9115749813288,-64.2399918461068],
  ["14147","Potrero de Garay","14147230","Componente de localidad compuesta",-31.7824159665775,-64.5424068778315],
  ["14147","Rafael García","14147240","Localidad simple",-31.6465373949134,-64.2584787728338],
  ["14147","San Clemente","14147250","Localidad simple",-31.7166546515515,-64.6265869046184],
  ["14147","San Nicolás - Tierra Alta","14147260","Localidad simple",-31.435151387072,-64.4492154097951],
  ["14147","Socavones","14147270","Localidad simple",-31.5300866657118,-64.1457832241514],
  ["14147","Toledo","14147280","Localidad simple",-31.5560967583723,-64.0080543306962],
  ["14147","Valle Alegre","14147290","Localidad simple",-31.608213303048,-64.4403684727464],
  ["14147","Valle de Anisacate","14147300","Componente de localidad compuesta",-31.7314776926852,-64.4129622125593],
  ["14147","Villa Ciudad de América","14147310","Localidad simple",-31.7944839463173,-64.5122651994167],
  ["14147","Villa del Prado","14147320","Localidad simple",-31.6179397578027,-64.3924925248834],
  ["14147","Villa La Bolsa","14147330","Componente de localidad compuesta",-31.7287879568356,-64.4324174982752],
  ["14147","Villa Los Aromos","14147340","Componente de localidad compuesta",-31.7359598057037,-64.4389279396961],
  ["14147","Villa Parque Santa Ana","14147350","Localidad simple",-31.5893075812486,-64.3536920462417],
  ["14147","Villa San Isidro","14147360","Localidad simple",-31.8208264119355,-64.3935275639835],
  ["14147","Villa Sierras De Oro","14147370","Localidad simple",-31.4579361723038,-64.4217153267522],
  ["14147","Yocsina","14147380","Localidad simple",-31.4470577243833,-64.3660748415952],
  ["14154","Caminiaga","14154010","Localidad simple",-30.0682250779624,-64.052875898278],
  ["14154","Chuña Huasi","14154030","Localidad simple",-29.9138372593106,-64.1299817960277],
  ["14154","Pozo Nuevo","14154040","Localidad simple",-29.5775456904692,-64.1070996245775],
  ["14154","San Francisco del Chañar","14154050","Localidad simple",-29.7882609409722,-63.9430703616826],
  ["14161","Almafuerte","14161010","Localidad simple",-32.1934604986786,-64.2543871859511],
  ["14161","Colonia Almada","14161020","Localidad simple",-32.033345652856,-63.8628846933814],
  ["14161","Corralito","14161030","Localidad simple",-32.0252572445237,-64.1931588929625],
  ["14161","Dalmacio Vélez","14161040","Localidad simple",-32.6108732524704,-63.5798837158317],
  ["14161","General Fotheringham","14161050","Localidad simple",-32.3234295842043,-63.8704257430147],
  ["14161","Hernando","14161060","Localidad simple",-32.4276148348373,-63.7330119093142],
  ["14161","James Craik","14161070","Localidad simple",-32.1613056379775,-63.4651919500633],
  ["14161","Las Isletillas","14161080","Localidad simple",-32.5100979867632,-63.929022935655],
  ["14161","Las Perdices","14161090","Localidad simple",-32.6981884459632,-63.7083103176214],
  ["14161","Los Zorros","14161100","Localidad simple",-32.045928188462,-63.201798166725],
  ["14161","Oliva","14161110","Localidad simple",-32.0413174021447,-63.5693820664827],
  ["14161","Pampayasta Norte","14161120","Componente de localidad compuesta",-32.2416827296709,-63.6421868735368],
  ["14161","Pampayasta Sud","14161130","Componente de localidad compuesta",-32.2507581145055,-63.6510140335346],
  ["14161","Punta del Agua","14161140","Localidad simple",-32.5754281748334,-63.8101580899516],
  ["14161","Río Tercero","14161150","Localidad simple",-32.173100971278,-64.1130560562283],
  ["14161","Tancacha","14161160","Localidad simple",-32.2402070251544,-63.9799466045503],
  ["14161","Villa Ascasubi","14161170","Localidad simple",-32.1643583032298,-63.8925588671839],
  ["14168","Candelaria Sur","14168010","Localidad simple",-30.8392305968427,-63.8008465946487],
  ["14168","Cañada de Luque","14168020","Localidad simple",-30.7370875150031,-63.723661877713],
  ["14168","Capilla de Sitón","14168030","Localidad simple",-30.5729640848008,-63.6517416910945],
  ["14168","Las Peñas","14168060","Localidad simple",-30.5617525961006,-64.0019842072006],
  ["14168","Los Mistoles","14168070","Localidad simple",-30.6259742943516,-63.886727301445],
  ["14168","Santa Catalina","14168080","Localidad simple",-30.8726236468488,-64.2313503284229],
  ["14168","Sarmiento","14168090","Localidad simple",-30.7741941000543,-64.1089868115808],
  ["14168","Simbolar","14168100","Localidad simple",-30.4752563998131,-63.9850395218446],
  ["14168","Sinsacate","14168110","Localidad simple",-30.9428574787407,-64.0884974374818],
  ["14168","Villa del Totoral","14168120","Localidad simple",-30.7038437425365,-64.0682991778579],
  ["14175","Churqui Cañada","14175020","Localidad simple",-30.1681571983317,-63.9295889316832],
  ["14175","El Rodeo","14175030","Localidad simple",-30.176079345889,-63.8679636143828],
  ["14175","El Tuscal","14175040","Localidad simple",-29.7574368770199,-64.5298988550679],
  ["14175","Las Arrias","14175050","Localidad simple",-30.3812826841011,-63.5966635615372],
  ["14175","Lucio V. Mansilla","14175060","Localidad simple",-29.8063717196573,-64.7065412644276],
  ["14175","Rosario del Saladillo","14175070","Localidad simple",-30.4293369124895,-63.4478615181188],
  ["14175","San José de la Dormida","14175080","Localidad simple",-30.3546018393412,-63.9466529209875],
  ["14175","San José de las Salinas","14175090","Localidad simple",-30.0090773891027,-64.6251344233407],
  ["14175","San Pedro Norte","14175100","Localidad simple",-30.0887589979373,-64.1559536726827],
  ["14175","Villa Tulumba","14175110","Localidad simple",-30.397481563929,-64.1231771567642],
  ["14182","Aldea Santa María","14182010","Localidad simple",-33.6948816087071,-62.9114758842793],
  ["14182","Alto Alegre","14182020","Localidad simple",-32.3460951978736,-62.8853485991764],
  ["14182","Ana Zumarán","14182030","Localidad simple",-32.3908244034289,-63.0574835050696],
  ["14182","Ballesteros","14182040","Localidad simple",-32.5453815879853,-62.9833005213374],
  ["14182","Ballesteros Sud","14182050","Localidad simple",-32.5885971215357,-63.0270387824819],
  ["14182","Bell Ville","14182060","Localidad simple",-32.6285600750707,-62.6891149083321],
  ["14182","Benjamín Gould","14182070","Localidad simple",-33.5901195408333,-62.7303890735445],
  ["14182","Canals","14182080","Localidad simple",-33.5623827183519,-62.8855974037259],
  ["14182","Chilibroste","14182090","Localidad simple",-32.3325969254244,-62.5135995097258],
  ["14182","Cintra","14182100","Localidad simple",-32.3081476332499,-62.6531184151953],
  ["14182","Colonia Bismarck","14182110","Localidad simple",-33.3003017093034,-62.7132986409449],
  ["14182","Colonia Bremen","14182120","Localidad simple",-33.4634972191589,-62.7323851196295],
  ["14182","Idiazabal","14182130","Localidad simple",-32.813142666622,-63.0329101219103],
  ["14182","Justiniano Posse","14182140","Localidad simple",-32.883580112369,-62.6802767037884],
  ["14182","Laborde","14182150","Localidad simple",-33.1529891830182,-62.8560737781526],
  ["14182","Monte Leña","14182160","Localidad simple",-32.6112897765276,-62.5903410387947],
  ["14182","Monte Maíz","14182170","Localidad simple",-33.2045620901114,-62.601248151355],
  ["14182","Morrison","14182180","Localidad simple",-32.5936423075986,-62.8360084604177],
  ["14182","Noetinger","14182190","Componente de localidad compuesta",-32.3667416426436,-62.312071766995],
  ["14182","Ordoñez","14182200","Localidad simple",-32.8412715334934,-62.866054921116],
  ["14182","Pascanas","14182210","Localidad simple",-33.1249872931372,-63.0426957377869],
  ["14182","Pueblo Italiano","14182220","Localidad simple",-33.880722767451,-62.8407250305138],
  ["14182","Ramón J. Cárcano","14182230","Localidad simple",-32.4911089118919,-63.1028075144055],
  ["14182","San Antonio de Litín","14182240","Localidad simple",-32.2128605395629,-62.6330068495678],
  ["14182","San Marcos","14182250","Localidad simple",-32.6303275526998,-62.4819712615844],
  ["14182","San Severo","14182260","Localidad simple",-33.5383254710795,-63.0479276785208],
  ["14182","Viamonte","14182270","Localidad simple",-33.7470669728167,-63.0989062265371],
  ["14182","Villa Los Patos","14182280","Localidad simple",-32.763745038404,-62.7277954886855],
  ["14182","Wenceslao Escalante","14182290","Localidad simple",-33.1720228484368,-62.7700003268955],
  ["18007","Bella Vista","18007010","Localidad simple",-28.507677249655,-59.04433283502],
  ["18014","Berón de Astrada","18014010","Localidad simple",-27.5506233626678,-57.5376245501398],
  ["18014","Yahapé","18014020","Localidad simple",-27.370426921625,-57.6552249966379],
  ["18021","Corrientes","18021020","Componente de localidad compuesta",-27.4632821641043,-58.8392333481757],
  ["18021","Laguna Brava","18021030","Localidad simple",-27.492827539732,-58.7167656641361],
  ["18021","Riachuelo","18021040","Localidad simple",-27.5811452851025,-58.7419831223036],
  ["18021","San Cayetano","18021050","Localidad simple",-27.5712103716288,-58.6958799100026],
  ["18028","Concepción","18028010","Localidad simple",-28.3924910085097,-57.8866807708097],
  ["18028","Santa Rosa","18028020","Localidad simple",-28.2674256970164,-58.1220612497619],
  ["18028","Tatacua","18028040","Localidad simple",-28.3720748439642,-58.3252896634835],
  ["18035","Cazadores Correntinos","18035010","Localidad simple",-29.9787827263917,-58.3024356720991],
  ["18035","Curuzú Cuatiá","18035020","Localidad simple",-29.7915233554051,-58.049945341682],
  ["18035","Perugorría","18035030","Localidad simple",-29.3404796154785,-58.6080890462901],
  ["18042","El Sombrero","18042010","Localidad simple",-27.7035440870919,-58.7686060583955],
  ["18042","Empedrado","18042020","Localidad simple",-27.9524556932224,-58.8074763893306],
  ["18049","Esquina","18049010","Localidad simple",-30.0159284150173,-59.5309812132883],
  ["18049","Pueblo Libertador","18049020","Localidad simple",-30.2195813152624,-59.3906028568407],
  ["18056","Alvear","18056010","Localidad simple",-29.0985990956679,-56.5521631297617],
  ["18056","Estación Torrent","18056020","Localidad simple",-28.8266239157245,-56.469525963544],
  ["18063","Itá Ibaté","18063010","Localidad simple",-27.4250661277127,-57.3376993601456],
  ["18063","Lomas de Vallejos","18063020","Localidad simple",-27.7329656323888,-57.9193852921423],
  ["06063","Villa Laguna La Brava","06063060","Localidad simple",-37.8596285282151,-57.9806008736401],
  ["18063","Nuestra Señora del Rosario de Caá Catí","18063030","Localidad simple",-27.751995828158,-57.6225136238666],
  ["18063","Palmar Grande","18063040","Localidad simple",-27.9407694115664,-57.9009156630285],
  ["18070","Carolina","18070010","Localidad simple",-29.1457706796124,-59.1820838282047],
  ["18070","Goya","18070020","Localidad simple",-29.1413439330685,-59.2605311638707],
  ["18077","Itatí","18077010","Localidad simple",-27.2693038533077,-58.2434782721968],
  ["18077","Ramada Paso","18077020","Localidad simple",-27.3659289314983,-58.3003087514316],
  ["18084","Colonia Liebig's","18084010","Componente de localidad compuesta",-27.9156591543749,-55.8233285990026],
  ["18084","Ituzaingó","18084020","Localidad simple",-27.5910429413741,-56.7039739448011],
  ["18084","San Antonio","18084030","Localidad simple",-27.5073854602181,-56.7411670700869],
  ["18084","San Carlos","18084040","Localidad simple",-27.745785086345,-55.9000479407003],
  ["18084","Villa Olivari","18084050","Localidad simple",-27.6329473311043,-56.9062014827101],
  ["18091","Cruz de los Milagros","18091010","Localidad simple",-28.8357350715385,-59.0068578339405],
  ["18091","Gobernador Juan E. Martínez","18091020","Localidad simple",-28.9108688742576,-58.9359577546112],
  ["18091","Lavalle","18091030","Localidad simple",-29.0249812495642,-59.1818570100087],
  ["18091","Santa Lucía","18091040","Localidad simple",-28.9847966992846,-59.1017576429993],
  ["18091","Villa Córdoba","18091050","Localidad simple",-28.9940335487267,-59.0774380130144],
  ["18091","Yatayti Calle","18091060","Localidad simple",-29.0295902166451,-58.9097321884448],
  ["18098","Mburucuyá","18098010","Localidad simple",-28.0460572855636,-58.224984006822],
  ["18105","Felipe Yofré","18105010","Localidad simple",-29.1059197645419,-58.3424746747141],
  ["18105","Mariano I. Loza","18105020","Localidad simple",-29.3763665588886,-58.1960231004583],
  ["18105","Mercedes","18105030","Localidad simple",-29.1833885579996,-58.0742364424806],
  ["18112","Colonia Libertad","18112010","Localidad simple",-30.0439760349315,-57.8235193980386],
  ["18112","Juan Pujol","18112030","Localidad simple",-30.4178964519869,-57.8560694385919],
  ["18112","Mocoretá","18112040","Localidad simple",-30.6176804049267,-57.9628254585589],
  ["18112","Monte Caseros","18112050","Localidad simple",-30.2515527236356,-57.6388140007913],
  ["18112","Parada Acuña","18112060","Localidad simple",-29.9084817138799,-57.9581770148793],
  ["18112","Parada Labougle","18112070","Localidad simple",-30.3190400199696,-57.7289868202181],
  ["18119","Bonpland","18119010","Localidad simple",-29.8203735190576,-57.4296479379825],
  ["18119","Parada Pucheta","18119020","Localidad simple",-29.9053454011034,-57.5743693513377],
  ["18119","Paso de los Libres","18119030","Localidad simple",-29.7116998596983,-57.0877441027999],
  ["18119","Tapebicuá","18119040","Localidad simple",-29.5043114402955,-56.9760306946844],
  ["18126","Saladas","18126010","Localidad simple",-28.2553374256058,-58.6238010038908],
  ["18126","San Lorenzo","18126020","Localidad simple",-28.1314603295453,-58.7668321022746],
  ["18133","Ingenio Primer Correntino","18133010","Localidad simple",-27.433672194702,-58.624327887603],
  ["18133","Paso de la Patria","18133020","Localidad simple",-27.3150060127599,-58.5720142980631],
  ["18133","San Cosme","18133030","Localidad simple",-27.3711801624716,-58.5115291113063],
  ["18133","Santa Ana","18133040","Localidad simple",-27.455091402543,-58.6530388459631],
  ["18140","San Luis del Palmar","18140010","Localidad simple",-27.5081078409756,-58.5554744159758],
  ["18147","Colonia Carlos Pellegrini","18147010","Localidad simple",-28.5373400329857,-57.1712310407172],
  ["18147","Guaviraví","18147020","Localidad simple",-29.3669865639555,-56.8292389472207],
  ["18147","La Cruz","18147030","Localidad simple",-29.1736584106926,-56.6450161726372],
  ["18147","Yapeyú","18147040","Localidad simple",-29.4706323042238,-56.8158358918792],
  ["18154","Loreto","18154010","Localidad simple",-27.7684514067067,-57.274839083927],
  ["18154","San Miguel","18154020","Localidad simple",-27.9947735055436,-57.5919539782996],
  ["18161","Chavarría","18161010","Localidad simple",-28.9549218176889,-58.5716489831846],
  ["18161","Colonia Pando","18161020","Localidad simple",-28.5252148833089,-58.4869345494056],
  ["18161","9 de Julio","18161030","Localidad simple",-28.8418348631681,-58.8280463835778],
  ["18161","Pedro R. Fernández","18161040","Localidad simple",-28.7505433489253,-58.6545368651224],
  ["18161","San Roque","18161050","Localidad simple",-28.5732308799035,-58.7100567505645],
  ["18168","José Rafael Gómez","18168010","Localidad simple",-28.2260143622167,-55.7844092003668],
  ["18168","Garruchos","18168020","Localidad simple",-28.1729435857266,-55.6513324031087],
  ["18168","Gobernador Igr. Valentín Virasoro","18168030","Localidad simple",-28.0455566790186,-56.0190197167242],
  ["18168","Santo Tomé","18168040","Localidad simple",-28.5511588178368,-56.0420862814163],
  ["18175","Sauce","18175010","Localidad simple",-30.0867528651818,-58.7879617250662],
  ["22007","Concepción del Bermejo","22007010","Localidad simple",-26.602273964006,-60.9492636999567],
  ["22007","Los Frentones","22007020","Localidad simple",-26.4082976307567,-61.4134271371596],
  ["22007","Pampa del Infierno","22007030","Localidad simple",-26.5063974406178,-61.1764901971888],
  ["22007","Río Muerto","22007040","Localidad simple",-26.3078818113872,-61.6540440649868],
  ["22007","Taco Pozo","22007050","Localidad simple",-25.6156598937138,-63.2692964997065],
  ["22014","General Vedia","22014010","Localidad simple",-26.9349378591637,-58.6612848328678],
  ["22014","Isla del Cerrito","22014020","Localidad simple",-27.2927852739485,-58.6178377359072],
  ["22014","La Leonesa","22014030","Componente de localidad compuesta",-27.0379596283785,-58.7069377183708],
  ["22014","Las Palmas","22014040","Componente de localidad compuesta",-27.0478975207771,-58.6795739267563],
  ["22014","Puerto Bermejo Nuevo","22014050","Localidad simple",-26.9073753724695,-58.5428316633795],
  ["22014","Puerto Bermejo Viejo","22014060","Localidad simple",-26.9285481385672,-58.5063036590574],
  ["22014","Puerto Eva Perón","22014070","Localidad simple",-26.661480092829,-58.6355818176746],
  ["22021","Presidencia Roque Sáenz Peña","22021010","Localidad simple",-26.7916058929378,-60.4421462814095],
  ["22028","Charata","22028010","Localidad simple",-27.2200458502784,-61.1915854495204],
  ["22036","Gancedo","22036010","Localidad simple",-27.4896487904756,-61.6738771708385],
  ["22036","General Capdevila","22036020","Localidad simple",-27.4231812966856,-61.4765845551068],
  ["22036","General Pinedo","22036030","Localidad simple",-27.3252979421708,-61.282210419911],
  ["22036","Mesón de Fierro","22036040","Localidad simple",-27.4312285767758,-61.0177584158265],
  ["22036","Pampa Landriel","22036050","Localidad simple",-27.3957449255406,-61.1029787390412],
  ["22039","Hermoso Campo","22039010","Localidad simple",-27.610539212014,-61.344844244037],
  ["22039","Itín","22039020","Localidad simple",-27.4876216159572,-61.3238818419592],
  ["22043","Chorotis","22043010","Localidad simple",-27.9175852858656,-61.3995694680726],
  ["22043","Santa Sylvina","22043020","Localidad simple",-27.8356008575455,-61.1361742191871],
  ["22043","Venados Grandes","22043030","Localidad simple",-27.8181539157701,-61.3815664200405],
  ["22049","Corzuela","22049010","Localidad simple",-26.9556760087163,-60.9707574059512],
  ["22056","La Escondida","22056010","Localidad simple",-27.1073248470025,-59.4475325100431],
  ["22056","La Verde","22056020","Localidad simple",-27.1297934337807,-59.3774619894491],
  ["22056","Lapachito","22056030","Localidad simple",-27.1587903465778,-59.3903975007013],
  ["22056","Makallé","22056040","Localidad simple",-27.2116185444409,-59.2883662132687],
  ["22063","El Espinillo","22063010","Localidad simple",-25.4176698636006,-60.4139677023547],
  ["22063","El Sauzal","22063020","Localidad simple",-24.579149375301,-61.5461702165926],
  ["22063","El Sauzalito","22063030","Localidad simple",-24.4345499393074,-61.6813716975805],
  ["22063","Fortín Lavalle","22063040","Localidad simple",-25.7056308542578,-60.2037478681132],
  ["22063","Fuerte Esperanza","22063050","Localidad simple",-25.1560600566744,-61.8424104268077],
  ["22063","Juan José Castelli","22063060","Localidad simple",-25.9504150377594,-60.6243211030425],
  ["22063","Miraflores","22063070","Localidad simple",-25.6489334968628,-60.9300401901344],
  ["22063","Nueva Pompeya","22063080","Localidad simple",-24.9334418837191,-61.4846998398146],
  ["22063","Villa Río Bermejito","22063100","Localidad simple",-25.6424413894079,-60.2629438807651],
  ["22063","Wichi","22063110","Localidad simple",-24.6913977720534,-61.4304454802334],
  ["22063","Zaparinqui","22063120","Localidad simple",-26.0673623556601,-60.5633873019222],
  ["22070","Avia Terai","22070010","Localidad simple",-26.6904269113097,-60.7309487066584],
  ["22070","Campo Largo","22070020","Localidad simple",-26.8038644067827,-60.8423032131182],
  ["22070","Fortín Las Chuñas","22070030","Localidad simple",-26.8891042551114,-60.908152214423],
  ["22070","Napenay","22070040","Localidad simple",-26.7314687114399,-60.6190285151237],
  ["22077","Colonia Popular","22077010","Localidad simple",-27.2759309408353,-59.1523781564389],
  ["22077","Estación General Obligado","22077020","Localidad simple",-27.4128679939929,-59.4201579706051],
  ["22077","Laguna Blanca","22077030","Localidad simple",-27.2572195505017,-59.2340486127892],
  ["22077","Puerto Tirol","22077040","Localidad simple",-27.3745125614532,-59.0953159917861],
  ["22084","Ciervo Petiso","22084010","Localidad simple",-26.5815849580294,-59.6329803967089],
  ["22084","General José de San Martín","22084020","Localidad simple",-26.5340730622708,-59.334711358946],
  ["22084","La Eduvigis","22084030","Localidad simple",-26.8374120457599,-59.0641175796047],
  ["22084","Laguna Limpia","22084040","Localidad simple",-26.4967013914467,-59.6799372880349],
  ["22084","Pampa Almirón","22084050","Localidad simple",-26.702247857191,-59.1237850343206],
  ["22084","Pampa del Indio","22084060","Localidad simple",-26.050714758193,-59.9412241077467],
  ["22084","Presidencia Roca","22084070","Localidad simple",-26.1402007626997,-59.5968452905131],
  ["22084","Selvas del Río de Oro","22084080","Localidad simple",-26.8044755779716,-58.9585454452622],
  ["22091","Tres Isletas","22091010","Localidad simple",-26.3378349285309,-60.4299349548752],
  ["22098","Coronel Du Graty","22098010","Localidad simple",-27.682571155615,-60.9091956314644],
  ["22098","Enrique Urien","22098020","Localidad simple",-27.5587251493486,-60.5259907543736],
  ["22098","Villa Angela","22098030","Localidad simple",-27.5788592432947,-60.7141120066309],
  ["22105","Las Breñas","22105010","Localidad simple",-27.0885167236059,-61.0836993088857],
  ["22112","La Clotilde","22112010","Localidad simple",-27.1781993384686,-60.6315741848516],
  ["22112","La Tigra","22112020","Localidad simple",-27.1157899755692,-60.5898941741226],
  ["22112","San Bernardo","22112030","Localidad simple",-27.2904384132605,-60.7149736332962],
  ["22119","Presidencia de la Plaza","22119010","Localidad simple",-27.0029714359347,-59.847600385659],
  ["22126","Barrio de los Pescadores","22126010","Localidad simple",-27.4480426212168,-58.8551013275047],
  ["22126","Colonia Benítez","22126020","Localidad simple",-27.3305884379906,-58.9450102746869],
  ["22126","Margarita Belén","22126030","Localidad simple",-27.2616473234151,-58.9741473116095],
  ["22133","Quitilipi","22133010","Localidad simple",-26.8732071732977,-60.2185241226399],
  ["22133","Villa El Palmar","22133020","Localidad simple",-26.4551186226266,-60.1646165913523],
  ["22140","Barranqueras","22140010","Componente de localidad compuesta",-27.487773928976,-58.9327416886365],
  ["22140","Basail","22140020","Localidad simple",-27.8868655966917,-59.2791003619491],
  ["22140","Colonia Baranda","22140030","Localidad simple",-27.5620449432874,-59.3096911774268],
  ["22140","Fontana","22140040","Componente de localidad compuesta",-27.4167127425858,-59.04393778912],
  ["22140","Puerto Vilelas","22140050","Componente de localidad compuesta",-27.5106090846354,-58.938994465923],
  ["22140","Resistencia","22140060","Componente de localidad compuesta",-27.4521194584549,-58.9876174408016],
  ["22147","Samuhú","22147010","Localidad simple",-27.5222254234698,-60.3941746057505],
  ["22147","Villa Berthet","22147020","Localidad simple",-27.2895492409257,-60.4155962080604],
  ["22154","Capitán Solari","22154010","Localidad simple",-26.8050732181614,-59.5596523744138],
  ["22154","Colonia Elisa","22154020","Localidad simple",-26.9324550960674,-59.5204851339372],
  ["22154","Colonias Unidas","22154030","Localidad simple",-26.7000971775462,-59.6277421824927],
  ["22154","Ingeniero Barbet","22154040","Localidad simple",-27.0032121063146,-59.4825136520473],
  ["22154","Las Garcitas","22154050","Localidad simple",-26.6193460346698,-59.8042763819042],
  ["22161","Charadai","22161010","Localidad simple",-27.6553304709616,-59.8624460245382],
  ["22161","Cote Lai","22161020","Localidad simple",-27.5303116601138,-59.5765171513905],
  ["22161","Haumonia","22161030","Localidad simple",-27.5077849029352,-60.1635277537413],
  ["22161","Horquilla","22161040","Localidad simple",-27.5427589336639,-59.9578541039413],
  ["22161","La Sabana","22161050","Localidad simple",-27.8738009106984,-59.939569589112],
  ["22168","Colonia Aborigen","22168010","Localidad simple",-26.9583436350996,-60.1902370459592],
  ["22168","Machagai","22168020","Localidad simple",-26.9287335504143,-60.0477196130638],
  ["22168","Napalpí","22168030","Localidad simple",-26.9032617040064,-60.1173839257013],
  ["26007","Arroyo Verde","26007010","Localidad simple",-42.0119886969656,-65.3064500926092],
  ["26007","Puerto Madryn","26007020","Localidad simple",-42.7550996783449,-65.0422298178163],
  ["26007","Puerto Pirámides","26007030","Localidad simple",-42.5736171931039,-64.2836893467339],
  ["26007","Quintas El Mirador","26007040","Localidad simple",-42.8115900131439,-65.0514178038049],
  ["26007","Reserva Area Protegida El Doradillo","26007050","Localidad simple",-42.6456158957863,-65.0647229672572],
  ["26014","Buenos Aires Chico","26014010","Localidad simple",-42.0687961260085,-71.2158343137726],
  ["26014","Cholila","26014020","Localidad simple",-42.5105313648355,-71.4351548288659],
  ["26014","Costa del Chubut","26014025","Localidad simple",-42.601625583604,-70.4575737273538],
  ["26014","Cushamen Centro","26014030","Localidad simple",-42.1766611028137,-70.662618842918],
  ["26014","El Hoyo","26014040","Localidad simple",-42.0679666637038,-71.5206708370903],
  ["26014","El Maitén","26014050","Localidad simple",-42.0542854358373,-71.1673153308386],
  ["26014","Epuyén","26014060","Localidad simple",-42.2329247123472,-71.3695066579513],
  ["26014","Fofo Cahuel","26014065","Localidad simple",-42.3910620005992,-70.5780784399414],
  ["26014","Gualjaina","26014070","Localidad simple",-42.7267578946733,-70.5354876126711],
  ["26014","Lago Epuyén","26014080","Localidad simple",-42.2135356830147,-71.4296625433553],
  ["26014","Lago Puelo","26014090","Localidad simple",-42.0672923130861,-71.5981575625236],
  ["26014","Leleque","26014100","Localidad simple",-42.4288626216315,-71.0683951630343],
  ["26021","Astra","26021010","Localidad simple",-45.7366075458208,-67.4852147282649],
  ["26021","Bahía Bustamante","26021020","Localidad simple",-45.1143552826118,-66.5349166167103],
  ["26021","Comodoro Rivadavia","26021030","Localidad simple",-45.8759553727581,-67.5146622308804],
  ["26021","Diadema Argentina","26021040","Localidad simple",-45.7906089158021,-67.6738925726169],
  ["26021","Rada Tilly","26021050","Localidad simple",-45.9368019185633,-67.5653960236573],
  ["26028","Camarones","26028010","Localidad simple",-44.79829087317,-65.710599293495],
  ["26028","Garayalde","26028020","Localidad simple",-44.6795783728661,-66.6097364550235],
  ["26035","Aldea Escolar (Los Rápidos)","26035010","Localidad simple",-43.1198187614025,-71.5588967458004],
  ["26035","Corcovado","26035020","Localidad simple",-43.5380021657326,-71.4659616215841],
  ["26035","Esquel","26035030","Localidad simple",-42.9133238858291,-71.3185116319277],
  ["06014","Vásquez","06014040","Localidad simple",-38.1766861391835,-60.1708487303777],
  ["26035","Lago Rosario","26035040","Localidad simple",-43.2500168518713,-71.3512318442886],
  ["26035","Los Cipreses","26035050","Localidad simple",-43.1847146210617,-71.6413919295155],
  ["26035","Trevelín","26035060","Localidad simple",-43.0908711905976,-71.4654853699539],
  ["26035","Villa Futalaufquen","26035070","Localidad simple",-42.9006375858067,-71.6061535113716],
  ["26042","Dique Florentino Ameghino","26042010","Localidad simple",-43.7032847513538,-66.479400323535],
  ["26042","Dolavon","26042020","Localidad simple",-43.309297578868,-65.7087388385691],
  ["26042","Gaiman","26042030","Localidad simple",-43.288807480447,-65.4924135000744],
  ["26042","28 de Julio","26042040","Localidad simple",-43.3809771295585,-65.8386877428491],
  ["26049","Blancuntre","26049010","Localidad simple",-42.5683892291525,-68.9190916237139],
  ["26049","El Escorial","26049020","Localidad simple",-43.0980700419589,-68.5596033354947],
  ["26049","Gastre","26049030","Localidad simple",-42.2656204565429,-69.2210978977662],
  ["26049","Lagunita Salada","26049040","Localidad simple",-42.7167792838299,-69.1884723935703],
  ["26049","Yala Laubat","26049050","Localidad simple",-42.7671354457615,-68.8754217944749],
  ["26056","Aldea Epulef","26056010","Localidad simple",-43.2341165952859,-69.7112937770404],
  ["26056","Carrenleufú","26056020","Localidad simple",-43.5856885437306,-71.7009020245021],
  ["26056","Colan Conhué","26056030","Localidad simple",-43.2425977048335,-69.9302181856069],
  ["26056","Paso del Sapo","26056040","Localidad simple",-42.7371109950872,-69.6110020875554],
  ["26056","Tecka","26056050","Localidad simple",-43.4935820815258,-70.8135608321009],
  ["26063","El Mirasol","26063010","Localidad simple",-43.285293271254,-67.7603113819649],
  ["26063","Las Plumas","26063020","Localidad simple",-43.7223979636171,-67.286995666614],
  ["26070","Cerro Cóndor","26070010","Localidad simple",-43.4233198653987,-69.1640923476749],
  ["26070","Los Altares","26070020","Localidad simple",-43.8711929981581,-68.4301168776513],
  ["26070","Paso de Indios","26070030","Localidad simple",-43.8663054117658,-69.0448870902309],
  ["26077","Playa Magagna","26077010","Localidad simple",-43.3821208618862,-65.0449325683673],
  ["26077","Playa Unión","26077020","Localidad simple",-43.3219408530217,-65.0475987350976],
  ["26077","Rawson","26077030","Localidad simple",-43.3010516778944,-65.0955202340428],
  ["26077","Trelew","26077040","Localidad simple",-43.2483538570309,-65.3103813319694],
  ["26084","Aldea Apeleg","26084010","Localidad simple",-44.7052521139583,-70.8460010136593],
  ["26084","Aldea Beleiro","26084020","Localidad simple",-45.5614644681207,-71.5181726162484],
  ["26084","Alto Río Senguer","26084030","Localidad simple",-45.0476417520383,-70.8227552077123],
  ["26084","Doctor Ricardo Rojas","26084040","Localidad simple",-45.5870084306304,-71.0290968422414],
  ["26084","Facundo","26084050","Localidad simple",-45.3192710383686,-69.9721127349677],
  ["26084","Lago Blanco","26084060","Localidad simple",-45.9468594190828,-71.2641106643113],
  ["26084","Río Mayo","26084070","Localidad simple",-45.6964538171738,-70.2559804482546],
  ["26091","Buen Pasto","26091010","Localidad simple",-45.0804225633305,-69.4497777721278],
  ["26091","Sarmiento","26091020","Localidad simple",-45.590519720018,-69.0706825167205],
  ["26098","Doctor Oscar Atilio Viglione (Frontera de Río Pico)","26098010","Localidad simple",-44.1988556500986,-71.6666681641387],
  ["26098","Gobernador Costa","26098020","Localidad simple",-44.0529826063176,-70.597920256446],
  ["26098","José de San Martín","26098030","Localidad simple",-44.0545030861499,-70.4698423450265],
  ["26098","Río Pico","26098040","Localidad simple",-44.1829932413496,-71.3700565360866],
  ["26105","Gan Gan","26105010","Localidad simple",-42.5232330288476,-68.2828542288869],
  ["26105","Telsen","26105020","Localidad simple",-42.4387511614213,-66.941427996482],
  ["30008","Arroyo Barú","30008010","Localidad simple",-31.8673630759862,-58.445702857466],
  ["30008","Colón","30008020","Localidad simple",-32.2232180852092,-58.1419674849484],
  ["30008","Colonia Hugues","30008030","Localidad simple",-32.2963657704418,-58.2329681221353],
  ["30008","Hambis","30008040","Localidad simple",-31.9629513486876,-58.5082059489741],
  ["30008","Hocker","30008050","Localidad simple",-32.0874958453901,-58.3417058444451],
  ["30008","La Clarita","30008060","Localidad simple",-31.9771375050248,-58.3917628888627],
  ["30008","Pueblo Cazes","30008070","Localidad simple",-32.0030492517654,-58.4934832589352],
  ["30008","Pueblo Liebig's","30008080","Localidad simple",-32.1570049045311,-58.1976616890773],
  ["30008","San José","30008090","Localidad simple",-32.2077198873635,-58.2187998664232],
  ["30008","Ubajay","30008100","Localidad simple",-31.7925728023428,-58.3158517356],
  ["30008","Villa Elisa","30008110","Localidad simple",-32.1606202225925,-58.4037483450693],
  ["30015","Calabacilla","30015010","Localidad simple",-31.507626297952,-58.1334346597166],
  ["30015","Clodomiro Ledesma","30015020","Localidad simple",-31.5794028169306,-58.1813678170213],
  ["30015","Colonia Ayuí","30015030","Localidad simple",-31.2050901632153,-58.0338899223591],
  ["30015","Colonia General Roca","30015040","Localidad simple",-31.3244065210985,-58.1214096714805],
  ["30015","Concordia","30015060","Localidad simple",-31.3881490852398,-58.016220398502],
  ["30015","Estación Yeruá","30015080","Localidad simple",-31.469433434517,-58.2636681024626],
  ["30015","Estación Yuquerí","30015083","Localidad simple",-31.3963812386954,-58.1611535438718],
  ["30015","Estancia Grande","30015087","Localidad simple",-31.4400282680775,-58.1246631255854],
  ["30015","La Criolla","30015090","Localidad simple",-31.2693712880357,-58.1060425422369],
  ["30015","Los Charrúas","30015100","Localidad simple",-31.1707840748941,-58.1873842951633],
  ["30015","Nueva Escocia","30015110","Localidad simple",-31.6473163855612,-58.0158126069679],
  ["30015","Osvaldo Magnasco","30015120","Localidad simple",-31.3125067390797,-58.0586009432166],
  ["30015","Pedernal","30015130","Localidad simple",-31.6714729659454,-58.2307912741944],
  ["30015","Puerto Yeruá","30015140","Localidad simple",-31.530833509471,-58.0128947749058],
  ["30021","Aldea Brasilera","30021010","Localidad simple",-31.8922864518526,-60.591797746941],
  ["30021","Aldea Grapschental","30021015","Localidad simple",-31.9563723140333,-60.4961051979678],
  ["30021","Aldea Protestante","30021020","Localidad simple",-32.0308328904873,-60.5643359117847],
  ["30021","Aldea Salto","30021030","Localidad simple",-31.9260358583331,-60.5483852721123],
  ["30021","Aldea San Francisco","30021040","Localidad simple",-31.9625681226479,-60.635713481626],
  ["30021","Aldea Spatzenkutter","30021050","Localidad simple",-31.9485292712546,-60.5803966416062],
  ["30021","Aldea Valle María","30021060","Localidad simple",-31.9922440087904,-60.5878502274446],
  ["30021","Colonia Ensayo","30021070","Localidad simple",-31.8672572611199,-60.5752901869571],
  ["30021","Diamante","30021080","Localidad simple",-32.0694175722366,-60.6372200354527],
  ["30021","Estación Camps","30021090","Localidad simple",-32.1133207438253,-60.2299017967384],
  ["30021","General Alvear","30021100","Localidad simple",-31.9494541080354,-60.6779497259324],
  ["30021","General Racedo (El Carmen)","30021110","Localidad simple",-31.9840164487261,-60.4083912285494],
  ["30021","General Ramírez","30021120","Localidad simple",-32.1772714430842,-60.1985605811767],
  ["30021","La Juanita","30021123","Localidad simple",-31.8753768018271,-60.649121973368],
  ["30021","Las Jaulas","30021127","Localidad simple",-31.8327184836082,-60.6048471558247],
  ["30021","Paraje La Virgen","30021130","Localidad simple",-31.917362571918,-60.653196880992],
  ["30021","Puerto Las Cuevas","30021140","Localidad simple",-32.3342284848162,-60.4872902471305],
  ["30021","Villa Libertador San Martín","30021150","Localidad simple",-32.0766327996549,-60.4638622644418],
  ["30028","Chajarí","30028010","Localidad simple",-30.7540759107669,-57.9841625878637],
  ["30028","Colonia Alemana","30028020","Localidad simple",-30.896158506292,-58.0221576342783],
  ["30028","Colonia La Argentina","30028040","Localidad simple",-31.07279911644,-58.0258605026584],
  ["30028","Colonia Peña","30028050","Localidad simple",-30.7974915997552,-58.1756384659062],
  ["30028","Federación","30028070","Localidad simple",-30.990072444489,-57.9183475208406],
  ["30028","Los Conquistadores","30028080","Localidad simple",-30.5944074579969,-58.4682627057869],
  ["30028","San Jaime de la Frontera","30028090","Localidad simple",-30.3396273493524,-58.3080915973688],
  ["30028","San Pedro","30028100","Localidad simple",-30.7571887237222,-58.0818713823153],
  ["30028","San Ramón","30028105","Localidad simple",-30.8091644325467,-58.2191269101013],
  ["30028","Santa Ana","30028110","Localidad simple",-30.9004970305733,-57.9310809529514],
  ["30028","Villa del Rosario","30028120","Localidad simple",-30.7968318611671,-57.9115719165535],
  ["30035","Conscripto Bernardi","30035010","Localidad simple",-31.0477778936084,-59.0867391405808],
  ["30035","Aldea San Isidro (El Cimarrón)","30035020","Localidad simple",-30.9868629826869,-58.9777569104134],
  ["30035","Federal","30035030","Localidad simple",-30.9513342178715,-58.7851418943148],
  ["30035","Nueva Vizcaya","30035040","Localidad simple",-30.9685149773302,-58.6127479285248],
  ["30035","Sauce de Luna","30035050","Localidad simple",-31.2384740579795,-59.2202829564802],
  ["30042","San José de Feliciano","30042010","Localidad simple",-30.3852713114912,-58.7515719602207],
  ["30042","San Víctor","30042020","Localidad simple",-30.4869283596556,-59.0316519541684],
  ["30049","Aldea Asunción","30049010","Localidad simple",-32.825171529429,-59.2312379231861],
  ["30049","Estación Lazo","30049020","Localidad simple",-32.8718397608117,-59.4223491853546],
  ["30049","General Galarza","30049030","Localidad simple",-32.7212713061818,-59.3958887031115],
  ["30049","Gualeguay","30049040","Localidad simple",-33.1485556234267,-59.3150160418816],
  ["30049","Puerto Ruiz","30049050","Localidad simple",-33.2198401773573,-59.3630338659967],
  ["30056","Aldea San Antonio","30056010","Localidad simple",-32.6253281653841,-58.703196864174],
  ["30056","Aldea San Juan","30056020","Localidad simple",-32.703788501225,-58.7790625010106],
  ["30056","Enrique Carbó","30056030","Localidad simple",-33.1478483564668,-59.2089401138297],
  ["30056","Estación Escriña","30056035","Localidad simple",-32.5932358304352,-58.9037416509556],
  ["30056","Faustino M. Parera","30056040","Localidad simple",-32.8044314283598,-58.8826333992369],
  ["30056","General Almada","30056050","Localidad simple",-32.8376334754538,-58.8038160467091],
  ["30056","Gilbert","30056060","Localidad simple",-32.5306030521064,-58.9339533000982],
  ["30056","Gualeguaychú","30056070","Componente de localidad compuesta",-33.0100328267382,-58.5164257946351],
  ["30056","Irazusta","30056080","Localidad simple",-32.9269373297111,-58.9534834763678],
  ["30056","Larroque","30056090","Localidad simple",-33.0354242763647,-59.001853656082],
  ["30056","Pastor Britos","30056095","Localidad simple",-32.7697426128614,-58.9070200410514],
  ["30056","Pueblo General Belgrano","30056100","Componente de localidad compuesta",-33.0162888459347,-58.476043760345],
  ["30056","Urdinarrain","30056110","Localidad simple",-32.6881311554333,-58.888994553976],
  ["30063","Ceibas","30063020","Localidad simple",-33.4994124052794,-58.8003541709834],
  ["30063","Ibicuy","30063030","Localidad simple",-33.7434364754781,-59.1552234337056],
  ["30063","Médanos","30063040","Localidad simple",-33.4360995740998,-59.0675952112197],
  ["30063","Villa Paranacito","30063060","Localidad simple",-33.7156244223002,-58.6597631447303],
  ["30070","Alcaraz","30070005","Localidad simple",-31.4565889671918,-59.5991388684545],
  ["30070","Bovril","30070010","Localidad simple",-31.3428914409424,-59.4467309737899],
  ["30070","Colonia Avigdor","30070020","Localidad simple",-31.1853384671792,-59.4079822910182],
  ["30070","El Solar","30070030","Localidad simple",-31.1810124666205,-59.7328844569416],
  ["30070","La Paz","30070040","Localidad simple",-30.741541104376,-59.6433535241896],
  ["30070","Piedras Blancas","30070050","Localidad simple",-31.1859575955508,-59.9521591252044],
  ["30070","San Gustavo","30070070","Localidad simple",-30.6905067150943,-59.3994540133514],
  ["30070","Santa Elena","30070080","Localidad simple",-30.9466589584952,-59.7882850384119],
  ["30070","Sir Leonard","30070090","Localidad simple",-31.3896679471814,-59.5032123815164],
  ["30077","Aranguren","30077010","Localidad simple",-32.2443130059944,-60.1627988186884],
  ["30077","Betbeder","30077020","Localidad simple",-32.374100868006,-59.9380818002549],
  ["30077","Don Cristóbal","30077030","Localidad simple",-32.0752594049271,-59.9943230195983],
  ["30077","Febré","30077040","Localidad simple",-32.4774515995652,-59.9217117300676],
  ["30077","Hernández","30077050","Localidad simple",-32.3380692970598,-60.0301404781048],
  ["30077","Lucas González","30077060","Localidad simple",-32.3859289481651,-59.531300464703],
  ["30077","Nogoyá","30077070","Localidad simple",-32.3956416421841,-59.7880764157544],
  ["30077","XX de Setiembre","30077080","Localidad simple",-32.3866241398752,-59.6630736582896],
  ["30084","Aldea María Luisa","30084010","Localidad simple",-31.8847292300203,-60.4087456869806],
  ["30084","Aldea San Juan","30084015","Localidad simple",-31.9982237404715,-60.3583819889242],
  ["30084","Aldea San Rafael","30084020","Localidad simple",-31.9598299451355,-60.2558755485286],
  ["30084","Aldea Santa María","30084030","Localidad simple",-31.6128701885629,-60.0070721806963],
  ["30084","Aldea Santa Rosa","30084040","Localidad simple",-32.0164544602725,-60.2411073474122],
  ["30084","Cerrito","30084050","Localidad simple",-31.5824984189512,-60.0770650212996],
  ["30084","Colonia Avellaneda","30084060","Componente de localidad compuesta",-31.7680690511493,-60.4050220629258],
  ["30084","Colonia Crespo","30084065","Localidad simple",-31.6777727008412,-60.2436880885317],
  ["30084","Crespo","30084070","Localidad simple",-32.0346491846505,-60.3107514290928],
  ["30084","El Palenque","30084080","Localidad simple",-31.6625748086746,-60.1751144821057],
  ["30084","El Pingo","30084090","Localidad simple",-31.5838497016925,-59.8938069366258],
  ["30084","El Ramblón","30084095","Localidad simple",-31.8480473768248,-60.0927487719843],
  ["30084","Hasenkamp","30084100","Localidad simple",-31.5133052410614,-59.83696962349],
  ["30084","Hernandarias","30084110","Localidad simple",-31.2324500702018,-59.9872576438234],
  ["30084","La Picada","30084120","Localidad simple",-31.7267100818149,-60.2971793004448],
  ["30084","Las Tunas","30084130","Localidad simple",-31.8706095724666,-59.7324361083485],
  ["30084","María Grande","30084140","Localidad simple",-31.6660715037636,-59.9044379252459],
  ["30084","Oro Verde","30084150","Componente de localidad compuesta",-31.8257355466309,-60.5182728163031],
  ["30084","Paraná","30084160","Componente de localidad compuesta",-31.7415676426411,-60.5284145917588],
  ["30084","Pueblo Bellocq (Las Garzas)","30084170","Localidad simple",-31.4287140394702,-59.7457885927193],
  ["30084","Pueblo Brugo","30084180","Localidad simple",-31.3883015926493,-60.0938334043815],
  ["30084","Pueblo General San Martín","30084190","Localidad simple",-31.4636064114686,-60.1679618601982],
  ["30084","San Benito","30084200","Componente de localidad compuesta",-31.7815218098022,-60.4419739913356],
  ["30084","Sauce Montrull","30084210","Componente de localidad compuesta",-31.7463194997657,-60.3552297078863],
  ["30084","Sauce Pinto","30084220","Localidad simple",-31.8442990730164,-60.3747483050584],
  ["30084","Seguí","30084230","Localidad simple",-31.9588750821276,-60.1269829104478],
  ["30084","Sosa","30084240","Localidad simple",-31.7385742726697,-59.9115081436489],
  ["30084","Tabossi","30084250","Localidad simple",-31.8047077554997,-59.9379151601641],
  ["30084","Tezanos Pinto","30084260","Localidad simple",-31.8735456198918,-60.4970235321194],
  ["30084","Viale","30084270","Localidad simple",-31.8714330822777,-60.0099225269048],
  ["30084","Villa Fontana","30084280","Localidad simple",-31.908647496665,-60.468352081106],
  ["30084","Villa Gdor. Luis F. Etchevehere","30084290","Localidad simple",-31.93428563973,-60.427973773299],
  ["30084","Villa Urquiza","30084300","Localidad simple",-31.6507506100701,-60.3775855159669],
  ["30088","General Campos","30088010","Localidad simple",-31.5246078338723,-58.4047735134447],
  ["30088","San Salvador","30088020","Localidad simple",-31.6255225523021,-58.5040738167895],
  ["30091","Altamirano Sur","30091010","Localidad simple",-32.0888342815838,-59.1740705545307],
  ["30091","Durazno","30091020","Localidad simple",-31.9865854200416,-59.2804623070461],
  ["30091","Estación Arroyo Clé","30091030","Localidad simple",-32.6338905298532,-59.4016108911944],
  ["30091","Gobernador Echagüe","30091040","Localidad simple",-32.3933701328502,-59.2758886814116],
  ["30091","Gobernador Mansilla","30091050","Localidad simple",-32.5464913620505,-59.3561472624329],
  ["06070","Baradero","06070010","Localidad simple",-33.8128781547156,-59.5043068852807],
  ["30091","Gobernador Solá","30091060","Localidad simple",-32.3372059083888,-59.3710906213647],
  ["30091","Guardamonte","30091070","Localidad simple",-32.0826358698135,-59.3082772238093],
  ["30091","Las Guachas","30091080","Localidad simple",-32.4700075443165,-59.1726625031425],
  ["30091","Maciá","30091090","Localidad simple",-32.1724413881098,-59.3986787086128],
  ["30091","Rosario del Tala","30091100","Localidad simple",-32.3026339163322,-59.1445792095518],
  ["30098","Basavilbaso","30098010","Localidad simple",-32.3725729351065,-58.8785609437917],
  ["30098","Caseros","30098020","Localidad simple",-32.4642772562474,-58.4780718727048],
  ["30098","Colonia Elía","30098030","Localidad simple",-32.6723717845853,-58.325119237234],
  ["30098","Concepción del Uruguay","30098040","Localidad simple",-32.4853601673728,-58.2320517380782],
  ["30098","Herrera","30098060","Localidad simple",-32.434613979879,-58.6330137118779],
  ["30098","Las Moscas","30098070","Localidad simple",-32.0926666859344,-58.9575923552081],
  ["30098","Líbaros","30098080","Localidad simple",-32.2629479332194,-58.9066108120783],
  ["30098","1º de Mayo","30098090","Localidad simple",-32.2570116072535,-58.422728628517],
  ["30098","Pronunciamiento","30098100","Localidad simple",-32.3456507831337,-58.4438591145895],
  ["30098","Rocamora","30098110","Localidad simple",-32.3459729612346,-58.9697454142681],
  ["30098","Santa Anita","30098120","Localidad simple",-32.1762466320214,-58.7864822456476],
  ["30098","Villa Mantero","30098130","Localidad simple",-32.3987091260597,-58.7440638984338],
  ["30098","Villa San Justo","30098140","Localidad simple",-32.446319897702,-58.4359138343848],
  ["30098","Villa San Marcial (Est. Gobernador Urquiza)","30098150","Localidad simple",-32.1800624013874,-58.9301272035017],
  ["30105","Antelo","30105010","Localidad simple",-32.5338102554011,-60.0356966118049],
  ["30105","Molino Doll","30105040","Localidad simple",-32.3100409280054,-60.4202063551195],
  ["30105","Victoria","30105060","Localidad simple",-32.6205968368011,-60.1533126380172],
  ["30113","Estación Raíces","30113010","Localidad simple",-31.9082390010537,-59.2607000636169],
  ["30113","Ingeniero Miguel Sajaroff","30113020","Localidad simple",-31.9569336301554,-58.8491174614017],
  ["30113","Jubileo","30113030","Localidad simple",-31.7336733349136,-58.634038044354],
  ["30113","Paso de la Laguna","30113050","Localidad simple",-31.8057649065599,-59.1651613714524],
  ["30113","Villa Clara","30113060","Localidad simple",-31.8301004555882,-58.8233903183527],
  ["30113","Villa Domínguez","30113070","Localidad simple",-31.9870146859479,-58.9634179145279],
  ["30113","Villaguay","30113080","Localidad simple",-31.8654413738655,-59.0290628351274],
  ["34007","Fortín Soledad","34007003","Localidad simple",-24.1576178222048,-60.6907628297081],
  ["34007","Guadalcazar","34007005","Localidad simple",-23.6823938545951,-61.1611089476784],
  ["34007","La Rinconada","34007007","Localidad simple",-23.4942751905754,-61.57638886946],
  ["34007","Laguna Yema","34007010","Localidad simple",-24.2554647197914,-61.2439980075435],
  ["34007","Lamadrid","34007015","Localidad simple",-23.9376982637237,-60.7400985635583],
  ["34007","Los Chiriguanos","34007020","Localidad simple",-24.0986835294011,-61.4675867695849],
  ["34007","Pozo de Maza","34007030","Localidad simple",-23.5691832483278,-61.7055334817331],
  ["34007","Pozo del Mortero","34007040","Localidad simple",-24.4064403681891,-61.031313748118],
  ["34007","Vaca Perdida","34007050","Localidad simple",-23.4948646893285,-61.6499982689001],
  ["34014","Colonia Pastoril","34014010","Localidad simple",-25.6701404606648,-58.2626302834096],
  ["34014","Formosa","34014020","Localidad simple",-26.1828223055764,-58.1733930549121],
  ["34014","Gran Guardia","34014030","Localidad simple",-25.8628496341956,-58.8859915019649],
  ["34014","Mariano Boedo","34014040","Localidad simple",-26.1106357408727,-58.4884270518243],
  ["34014","Mojón de Fierro","34014050","Localidad simple",-26.0345119719636,-58.0499307616902],
  ["34014","San Hilario","34014060","Localidad simple",-26.0248676792093,-58.6500726228772],
  ["34014","Villa del Carmen","34014070","Localidad simple",-26.2522590977589,-58.2525528690149],
  ["34021","Banco Payaguá","34021010","Localidad simple",-26.7071297025561,-58.3390745827256],
  ["34021","General Lucio V. Mansilla","34021020","Localidad simple",-26.654180225538,-58.6293214756534],
  ["34021","Herradura","34021030","Localidad simple",-26.4874646396691,-58.3122424597995],
  ["34021","San Francisco de Laishi","34021040","Localidad simple",-26.2423010252437,-58.6300642415105],
  ["34021","Tatané","34021050","Localidad simple",-26.3987186827879,-58.3575600493034],
  ["34021","Villa Escolar","34021060","Localidad simple",-26.6211844819298,-58.6718336940894],
  ["34028","Ingeniero Guillermo N. Juárez","34028010","Localidad simple",-23.8976004129254,-61.8538220483946],
  ["34035","Bartolomé de las Casas","34035010","Localidad simple",-25.3474022268881,-59.6181476016645],
  ["34035","Colonia Sarmiento","34035020","Localidad simple",-24.6444789665474,-59.4332808273711],
  ["34035","Comandante Fontana","34035030","Localidad simple",-25.3347934740298,-59.6828071882955],
  ["34035","El Recreo","34035040","Localidad simple",-25.0663152545433,-59.2513514627224],
  ["34035","Estanislao del Campo","34035050","Localidad simple",-25.053192264735,-60.0939271832043],
  ["34035","Fortín Cabo 1º Lugones","34035060","Localidad simple",-24.2854864616665,-59.8282499173384],
  ["34035","Fortín Sargento 1º Leyes","34035070","Localidad simple",-24.5503048524758,-59.390271557059],
  ["34035","Ibarreta","34035080","Localidad simple",-25.2113191232301,-59.8570398440914],
  ["34035","Juan G. Bazán","34035090","Localidad simple",-24.5418137126365,-60.8341896995338],
  ["34035","Las Lomitas","34035100","Localidad simple",-24.7105776136691,-60.5937892586838],
  ["34035","Posta Cambio Zalazar","34035110","Localidad simple",-24.2115848629554,-60.198666969414],
  ["34035","Pozo del Tigre","34035120","Localidad simple",-24.8975997693171,-60.3187890218463],
  ["34035","San Martín I","34035130","Localidad simple",-24.5319053014019,-59.902051229705],
  ["34035","San Martín II","34035140","Localidad simple",-24.4331529800639,-59.656351890373],
  ["34035","Subteniente Perín","34035150","Localidad simple",-25.5350397293764,-60.0190827630116],
  ["34035","Villa General Güemes","34035160","Localidad simple",-24.7529456908497,-59.4916405606824],
  ["34035","Villa General Manuel Belgrano","34035170","Localidad simple",-24.9388283555888,-59.02908772779],
  ["34042","Buena Vista","34042010","Localidad simple",-25.0712122663672,-58.3867799081037],
  ["34042","El Espinillo","34042020","Localidad simple",-24.9799888263685,-58.5537877142505],
  ["34042","Laguna Gallo","34042030","Localidad simple",-25.2677752833691,-58.7427948347143],
  ["34042","Misión Tacaaglé","34042040","Localidad simple",-24.979650567657,-58.8227434439731],
  ["34042","Portón Negro","34042050","Localidad simple",-24.9663598975615,-58.7419749100008],
  ["34042","Tres Lagunas","34042060","Localidad simple",-25.2153644371658,-58.5132694906705],
  ["34049","Clorinda","34049010","Localidad simple",-25.2921612747741,-57.7178091082588],
  ["34049","Laguna Blanca","34049020","Localidad simple",-25.1302522059542,-58.245843025824],
  ["34049","Laguna Naick-Neck","34049030","Localidad simple",-25.2193910506961,-58.1230791260522],
  ["34049","Palma Sola","34049040","Localidad simple",-25.2475512345955,-57.9768403788082],
  ["34049","Puerto Pilcomayo","34049050","Localidad simple",-25.3688131700971,-57.6524943008573],
  ["34049","Riacho He-He","34049060","Localidad simple",-25.3617117019838,-58.2782518825352],
  ["34049","Riacho Negro","34049070","Localidad simple",-25.4224320225992,-57.7914545139812],
  ["34049","Siete Palmas","34049080","Localidad simple",-25.2015076619063,-58.330676377416],
  ["34056","Colonia Campo Villafañe","34056010","Localidad simple",-26.2048681517277,-59.07803318034],
  ["34056","El Colorado","34056020","Localidad simple",-26.3117354640006,-59.3684434678409],
  ["34056","Palo Santo","34056030","Localidad simple",-25.5639063797961,-59.3360059836081],
  ["34056","Pirané","34056040","Localidad simple",-25.7306417902345,-59.1075205904774],
  ["34056","Villa Kilómetro 213","34056050","Localidad simple",-26.1864626491659,-59.3683950578867],
  ["34063","El Potrillo","34063010","Localidad simple",-23.1607663192891,-62.0107787024286],
  ["34063","General Mosconi","34063020","Localidad simple",-23.1827186246626,-62.3040685442409],
  ["34063","El Quebracho","34063030","Localidad simple",-23.3394869143818,-61.8734659544108],
  ["38007","Abdón Castro Tolay","38007010","Localidad simple",-23.3419368713503,-66.0901014487309],
  ["38007","Abra Pampa","38007020","Localidad simple",-22.7223526298672,-65.6965045525232],
  ["38007","Abralaite","38007030","Localidad simple",-23.1692063444784,-65.7944004862785],
  ["38007","Agua de Castilla","38007035","Localidad simple",-23.2167374833476,-65.8082738847531],
  ["38007","Casabindo","38007040","Localidad simple",-22.9850219724833,-66.0328013633041],
  ["38007","Cochinoca","38007050","Localidad simple",-22.744265021174,-65.8951221139841],
  ["38007","La Redonda","38007055","Localidad simple",-22.5294608585997,-65.5222832606241],
  ["38007","Puesto del Marquéz","38007060","Localidad simple",-22.5384288906185,-65.6978923774993],
  ["38007","Quebraleña","38007063","Localidad simple",-23.2857891128732,-65.7701494793729],
  ["38007","Quera","38007067","Localidad simple",-23.100830176506,-65.7627638222671],
  ["38007","Rinconadillas","38007070","Localidad simple",-23.3846029198326,-65.9573754338264],
  ["38007","San Francisco de Alfarcito","38007080","Localidad simple",-23.3198701399198,-65.9744058851841],
  ["38007","Santa Ana de la Puna","38007085","Localidad simple",-23.1248833823314,-66.0521610363099],
  ["38007","Santuario de Tres Pozos","38007090","Localidad simple",-23.533244846401,-65.9632841858024],
  ["38007","Tambillos","38007095","Localidad simple",-22.8968709361119,-65.9620225137436],
  ["38007","Tusaquillas","38007100","Localidad simple",-23.1901128134571,-65.9890162373631],
  ["38014","Aguas Calientes","38014010","Localidad simple",-24.5848393910268,-64.9239793842822],
  ["38014","Barrio El Milagro","38014020","Localidad simple",-24.4610014305425,-65.1190583597652],
  ["38014","Barrio La Unión","38014030","Localidad simple",-24.4043300097514,-65.0697401829896],
  ["38014","El Carmen","38014040","Localidad simple",-24.3891095885225,-65.2605453068598],
  ["38014","Los Lapachos","38014050","Localidad simple",-24.4759200783409,-65.0776012050616],
  ["38014","Loteo San Vicente","38014055","Localidad simple",-24.4293248380693,-65.1843971543033],
  ["38014","Manantiales","38014060","Localidad simple",-24.5336970280067,-64.9771546670321],
  ["38014","Monterrico","38014070","Localidad simple",-24.4421177051028,-65.1622505537209],
  ["38014","Pampa Blanca","38014080","Localidad simple",-24.5325323540548,-65.0742522158109],
  ["38014","Perico","38014090","Localidad simple",-24.3807802774745,-65.1162073560982],
  ["38014","Puesto Viejo","38014100","Localidad simple",-24.485003513907,-64.9670262152006],
  ["38014","San Isidro","38014110","Localidad simple",-24.5556368462513,-64.9424207944567],
  ["38014","San Juancito","38014120","Localidad simple",-24.3843856940085,-64.9937381095943],
  ["38021","Guerrero","38021010","Localidad simple",-24.1859719091941,-65.4487115603426],
  ["38021","La Almona","38021020","Localidad simple",-24.2656799176145,-65.3972038835292],
  ["38021","León","38021030","Localidad simple",-24.0395227299023,-65.4309577730475],
  ["38021","Lozano","38021040","Localidad simple",-24.0820553565565,-65.4037790153252],
  ["38021","Ocloyas","38021050","Localidad simple",-23.9440584396018,-65.2322154882925],
  ["38021","San Salvador de Jujuy","38021060","Componente de localidad compuesta",-24.1844139008337,-65.3039986701092],
  ["38021","Tesorero","38021065","Localidad simple",-23.9486188183993,-65.2985111585154],
  ["38021","Yala","38021070","Componente de localidad compuesta",-24.1234541496883,-65.401435505228],
  ["38028","Aparzo","38028003","Localidad simple",-23.0992150250753,-65.1865385997584],
  ["38028","Cianzo","38028007","Localidad simple",-23.1732331272464,-65.1578176759527],
  ["38028","Coctaca","38028010","Localidad simple",-23.1543348556287,-65.2936644075552],
  ["38028","El Aguilar","38028020","Localidad simple",-23.2139846798174,-65.6788754303526],
  ["38028","Hipólito Yrigoyen","38028030","Localidad simple",-22.9790987916947,-65.3527979015935],
  ["38028","Humahuaca","38028040","Localidad simple",-23.2118256384836,-65.3507419495251],
  ["38028","Palca de Aparzo","38028043","Localidad simple",-23.1220406414082,-65.134806337775],
  ["38028","Palca de Varas","38028045","Localidad simple",-23.1018612642193,-65.112920847023],
  ["38028","Rodero","38028047","Localidad simple",-23.0621839336364,-65.3260425196352],
  ["38028","Tres Cruces","38028050","Localidad simple",-22.9169380002989,-65.5878327366614],
  ["38028","Uquía","38028060","Localidad simple",-23.3041905968327,-65.356558164038],
  ["38035","Bananal","38035010","Localidad simple",-23.565439613584,-64.501163197896],
  ["38035","Bermejito","38035020","Localidad simple",-23.7881113454008,-64.73005792215],
  ["38035","Caimancito","38035030","Localidad simple",-23.7390273358675,-64.5927674367985],
  ["38035","Calilegua","38035040","Localidad simple",-23.77580785145,-64.7714502012243],
  ["38035","Chalicán","38035050","Localidad simple",-24.0701319470485,-64.8068636697633],
  ["38035","Fraile Pintado","38035060","Localidad simple",-23.9420214191485,-64.8029446573235],
  ["38035","Libertad","38035070","Localidad simple",-23.7623858141283,-64.7259945367992],
  ["38035","Libertador General San Martín","38035080","Localidad simple",-23.8091072493712,-64.7927821518223],
  ["38035","Maíz Negro","38035090","Localidad simple",-23.9506323797642,-64.7736232797616],
  ["38035","Paulina","38035100","Localidad simple",-23.8445381270952,-64.7389846268417],
  ["38035","Yuto","38035110","Localidad simple",-23.6473910528443,-64.4683378490048],
  ["38042","Carahunco","38042010","Localidad simple",-24.3076479727425,-65.0834468981217],
  ["38042","Centro Forestal","38042020","Localidad simple",-24.2287296415511,-65.1776468508489],
  ["38042","Palpalá","38042040","Componente de localidad compuesta",-24.2529660001884,-65.1981859947647],
  ["38049","Casa Colorada","38049003","Localidad simple",-22.3253946072654,-66.2837654791341],
  ["38049","Coyaguaima","38049007","Localidad simple",-22.7704435619992,-66.440426993556],
  ["38049","Lagunillas de Farallón","38049010","Localidad simple",-22.4621492240335,-66.6281060495323],
  ["38049","Liviara","38049020","Localidad simple",-22.5205427089875,-66.3370942259576],
  ["38049","Loma Blanca","38049025","Localidad simple",-22.4715310141327,-66.4842002316312],
  ["38049","Nuevo Pirquitas","38049030","Localidad simple",-22.6879554218994,-66.4563756677863],
  ["38049","Orosmayo","38049035","Localidad simple",-22.5570555914003,-66.3563627312908],
  ["38049","Rinconada","38049040","Localidad simple",-22.4403477816105,-66.1673735179392],
  ["38056","El Ceibal","38056010","Localidad simple",-24.3013918074401,-65.2794378200693],
  ["38056","Los Alisos","38056017","Localidad simple",-24.2694294471429,-65.3038293509073],
  ["38056","Loteo Navea","38056020","Localidad simple",-24.2701433897522,-65.2740648045537],
  ["38056","Nuestra Señora del Rosario","38056025","Localidad simple",-24.3184045981955,-65.400922691233],
  ["38056","San Antonio","38056030","Localidad simple",-24.3672400343176,-65.3377007673345],
  ["38063","Arrayanal","38063010","Localidad simple",-24.1768075323298,-64.8403333563822],
  ["38063","Arroyo Colorado","38063020","Localidad simple",-24.3365556568725,-64.6635805195006],
  ["38063","Don Emilio","38063030","Localidad simple",-24.3167328574824,-64.9078893331684],
  ["38063","El Acheral","38063040","Localidad simple",-24.4035872902003,-64.8010495450204],
  ["38063","El Puesto","38063050","Localidad simple",-24.1989198465405,-64.7892891441781],
  ["38063","El Quemado","38063060","Localidad simple",-24.1058565563838,-64.823062158756],
  ["38063","La Esperanza","38063070","Componente de localidad compuesta",-24.2237083446708,-64.8373717906106],
  ["38063","La Manga","38063080","Localidad simple",-24.191027398496,-64.847140304232],
  ["38063","La Mendieta","38063090","Localidad simple",-24.3164922129456,-64.9670192886887],
  ["38063","Miraflores","38063100","Componente de localidad compuesta",-24.2247852710015,-64.8201208754984],
  ["38063","Palos Blancos","38063110","Localidad simple",-24.3269093157963,-64.9472509634032],
  ["38063","Parapetí","38063120","Localidad simple",-24.2364439472659,-64.8448511951718],
  ["38063","Piedritas","38063130","Localidad simple",-24.2961714666534,-64.8821863479763],
  ["38063","Rodeito","38063140","Localidad simple",-24.2716140097952,-64.768970964685],
  ["38063","Rosario de Río Grande (ex Barro Negro)","38063150","Localidad simple",-24.3085245850739,-64.9316446809993],
  ["38063","San Antonio","38063160","Localidad simple",-24.219671559876,-64.8045172910273],
  ["38063","San Lucas","38063170","Localidad simple",-24.2685961573007,-64.8642893202695],
  ["38063","San Pedro","38063180","Componente de localidad compuesta",-24.2313021129281,-64.8681693070463],
  ["38063","Sauzal","38063190","Localidad simple",-24.2987583243037,-64.9571556712013],
  ["38070","El Fuerte","38070010","Localidad simple",-24.260560497029,-64.4155132039794],
  ["38070","El Piquete","38070020","Localidad simple",-24.1791481712823,-64.6776330087428],
  ["38070","El Talar","38070030","Localidad simple",-23.5555611045113,-64.3643099072085],
  ["38070","Palma Sola","38070040","Localidad simple",-23.9678426401893,-64.3034683351392],
  ["38070","Puente Lavayén","38070050","Localidad simple",-24.2725269338812,-64.7161865903698],
  ["38070","Santa Clara","38070060","Localidad simple",-24.3078151766845,-64.6610648577922],
  ["38070","Vinalito","38070070","Localidad simple",-23.6681883228337,-64.4131178374229],
  ["38077","Casira","38077010","Localidad simple",-21.9788187103851,-65.8958558436093],
  ["38077","Ciénega de Paicone","38077020","Localidad simple",-22.1769689683858,-66.4139607069095],
  ["38077","Cieneguillas","38077030","Localidad simple",-22.1009002170764,-65.867209693443],
  ["38077","Cusi Cusi","38077040","Localidad simple",-22.3402234558008,-66.4926397388327],
  ["38077","El Angosto","38077045","Localidad simple",-21.8764898712784,-66.1886427089451],
  ["38077","La Ciénega","38077050","Localidad simple",-21.9606332568994,-66.263084676456],
  ["38077","Misarrumi","38077060","Localidad simple",-22.2593865040609,-66.3668608819379],
  ["38077","Oratorio","38077070","Localidad simple",-22.0991710039884,-66.1325561087962],
  ["38077","Paicone","38077080","Localidad simple",-22.2193202745887,-66.4252604137157],
  ["38077","San Juan de Oros","38077090","Localidad simple",-22.2243859011206,-66.2489981842614],
  ["38077","Santa Catalina","38077100","Localidad simple",-21.9457402673178,-66.0524460482788],
  ["38077","Yoscaba","38077110","Localidad simple",-22.1671932548934,-66.0247356350831],
  ["38084","Catua","38084010","Localidad simple",-23.8697878292198,-67.0052751921339],
  ["38084","Coranzuli","38084020","Localidad simple",-23.0145482730193,-66.3666374411625],
  ["38084","El Toro","38084030","Localidad simple",-23.0836526940797,-66.7015910904292],
  ["38084","Huáncar","38084040","Localidad simple",-23.5638430752997,-66.4093156495626],
  ["38084","Jama","38084045","Localidad simple",-23.2381696240536,-67.0272646457146],
  ["38084","Mina Providencia","38084050","Localidad simple",-23.2654412559675,-66.65566212419],
  ["38084","Olacapato","38084055","Localidad simple",-24.1152805507803,-66.7186508694002],
  ["38084","Olaroz Chico","38084060","Localidad simple",-23.3934649138842,-66.8017391151812],
  ["38084","Pastos Chicos","38084070","Localidad simple",-23.7667799522763,-66.4362241723231],
  ["38084","Puesto Sey","38084080","Localidad simple",-23.9450800745364,-66.4880705176388],
  ["38084","San Juan de Quillaqués","38084090","Localidad simple",-23.2303525084842,-66.3437115747179],
  ["38084","Susques","38084100","Localidad simple",-23.3993487788994,-66.3663509046119],
  ["38094","Colonia San José","38094010","Localidad simple",-23.3926096474539,-65.3451196617441],
  ["38094","Huacalera","38094020","Localidad simple",-23.4369569456923,-65.3498233567527],
  ["38094","Juella","38094030","Localidad simple",-23.5175106247741,-65.4081712327054],
  ["38094","Maimará","38094040","Localidad simple",-23.6251650641141,-65.4090898914489],
  ["38094","Tilcara","38094050","Localidad simple",-23.5758626116634,-65.3936940685486],
  ["38098","Bárcena","38098010","Localidad simple",-23.9826097875936,-65.4550931589626],
  ["38098","El Moreno","38098020","Localidad simple",-23.850911537998,-65.8316510262887],
  ["38098","Puerta de Colorados","38098025","Localidad simple",-23.5715104796996,-65.698000202945],
  ["38098","Purmamarca","38098030","Localidad simple",-23.7450544260753,-65.5003903899528],
  ["38098","Tumbaya","38098040","Localidad simple",-23.8561961637236,-65.4663650677456],
  ["38098","Volcán","38098050","Localidad simple",-23.9165986512201,-65.4655058903446],
  ["38105","Caspalá","38105010","Localidad simple",-23.3626169910686,-65.0914951382906],
  ["38105","Pampichuela","38105020","Localidad simple",-23.5548845300142,-65.0066887909795],
  ["38105","San Francisco","38105030","Localidad simple",-23.6213393482903,-64.9501640840904],
  ["38105","Santa Ana","38105040","Localidad simple",-23.3564321535763,-64.9877247699547],
  ["38105","Valle Colorado","38105050","Localidad simple",-23.4139544374567,-64.93377255055],
  ["38105","Valle Grande","38105060","Localidad simple",-23.4758465611017,-64.9469047343162],
  ["38112","Barrios","38112010","Localidad simple",-22.2477578344269,-65.529042968307],
  ["38112","Cangrejillos","38112020","Localidad simple",-22.423791437897,-65.579872144671],
  ["38112","El Cóndor","38112030","Localidad simple",-22.3866192862254,-65.3395952168589],
  ["38112","La Intermedia","38112040","Localidad simple",-22.4230485492938,-65.7004227358985],
  ["38112","La Quiaca","38112050","Localidad simple",-22.1064369293997,-65.5957257876868],
  ["38112","Llulluchayoc","38112060","Localidad simple",-22.5507612616611,-65.3872645925388],
  ["38112","Pumahuasi","38112070","Localidad simple",-22.2899363240929,-65.6798827753743],
  ["38112","Yavi","38112080","Localidad simple",-22.1299850014618,-65.4614703321096],
  ["38112","Yavi Chico","38112090","Localidad simple",-22.0983777844843,-65.4559189939558],
  ["42007","Doblas","42007010","Localidad simple",-37.1521838816608,-64.0140550927574],
  ["42007","Macachín","42007020","Localidad simple",-37.1369555361687,-63.667141835534],
  ["42007","Miguel Riglos","42007030","Localidad simple",-36.8538749058938,-63.6881846143541],
  ["42007","Rolón","42007040","Localidad simple",-37.166824214775,-63.4171582009534],
  ["42007","Tomás M. Anchorena","42007050","Localidad simple",-36.8406606874148,-63.5205021645149],
  ["42014","Anzoátegui","42014010","Localidad simple",-38.963052676569,-63.8608882456791],
  ["42014","La Adela","42014020","Componente de localidad compuesta",-38.9739618507806,-64.0893166949511],
  ["42021","Anguil","42021010","Localidad simple",-36.527922625355,-64.0105558979729],
  ["42021","Santa Rosa","42021020","Componente de localidad compuesta",-36.61828979857,-64.2916770389461],
  ["42028","Catriló","42028010","Localidad simple",-36.4077407331528,-63.4231236479695],
  ["42028","La Gloria","42028020","Localidad simple",-36.5079177159884,-63.7444083139952],
  ["42028","Lonquimay","42028030","Localidad simple",-36.4676263417811,-63.6237223449231],
  ["42028","Uriburu","42028040","Localidad simple",-36.5077574745038,-63.8626307655783],
  ["42035","Conhelo","42035010","Localidad simple",-35.9994878462166,-64.5959233383524],
  ["42035","Eduardo Castex","42035020","Localidad simple",-35.916589710926,-64.2945868368038],
  ["42035","Mauricio Mayer","42035030","Localidad simple",-36.2106631640542,-64.0335412257945],
  ["42035","Monte Nievas","42035040","Localidad simple",-35.8617464058389,-64.1569675208376],
  ["42035","Rucanelo","42035050","Localidad simple",-36.0429376779565,-64.8353214769324],
  ["42035","Winifreda","42035060","Localidad simple",-36.2272741396174,-64.2348767956417],
  ["42042","Gobernador Duval","42042010","Localidad simple",-38.7413407663938,-66.4360653362481],
  ["42042","Puelches","42042020","Localidad simple",-38.1437722310811,-65.9102790812434],
  ["42049","Santa Isabel","42049010","Localidad simple",-36.2298585551973,-66.9416696902043],
  ["42056","Bernardo Larroude","42056010","Localidad simple",-35.0240766140268,-63.5814786778188],
  ["42056","Ceballos","42056020","Localidad simple",-35.2904849982904,-63.77586064487],
  ["42056","Coronel Hilario Lagos","42056030","Localidad simple",-35.0223098759754,-63.9123145859877],
  ["42056","Intendente Alvear","42056040","Localidad simple",-35.2368693365619,-63.5923274522769],
  ["42056","Sarah","42056050","Localidad simple",-35.0246923056998,-63.686962377693],
  ["42056","Vértiz","42056060","Localidad simple",-35.4262411079929,-63.9063646669037],
  ["42063","Algarrobo del Águila","42063010","Localidad simple",-36.4011467185658,-67.1484015946157],
  ["42063","La Humada","42063020","Localidad simple",-36.3500276379509,-68.0141950027482],
  ["42070","Alpachiri","42070010","Localidad simple",-37.3758811926005,-63.7738735909084],
  ["42070","General Manuel J. Campos","42070020","Localidad simple",-37.4589894326191,-63.5872408548873],
  ["42070","Guatraché","42070030","Localidad simple",-37.6669652272263,-63.5415367289386],
  ["42070","Perú","42070040","Localidad simple",-37.66238494384,-64.1373213494442],
  ["42070","Santa Teresa","42070050","Localidad simple",-37.5749339058947,-63.4328864695669],
  ["42077","Abramo","42077010","Localidad simple",-37.8943313295474,-63.8515025914131],
  ["42077","Bernasconi","42077020","Localidad simple",-37.9020681912484,-63.7450793526802],
  ["42077","General San Martín","42077030","Localidad simple",-37.9785301335454,-63.6065854529976],
  ["42077","Hucal","42077040","Localidad simple",-37.7849629183535,-64.0306677804584],
  ["42077","Jacinto Aráuz","42077050","Localidad simple",-38.0837587172211,-63.4321816643775],
  ["42084","Cuchillo Co","42084010","Localidad simple",-38.3336784745407,-64.6422526958764],
  ["42091","La Reforma","42091010","Localidad simple",-37.5520049423349,-66.2268538972728],
  ["42091","Limay Mahuida","42091020","Localidad simple",-37.1597120530545,-66.6745400356471],
  ["42098","Carro Quemado","42098010","Localidad simple",-36.47556498406,-65.3429160249895],
  ["42098","Loventué","42098020","Localidad simple",-36.1887459763907,-65.2899702728719],
  ["42098","Luan Toro","42098030","Localidad simple",-36.2016818772905,-65.0972782402489],
  ["42098","Telén","42098040","Localidad simple",-36.2640564040186,-65.5097731802402],
  ["42098","Victorica","42098050","Localidad simple",-36.2048593679219,-65.4403752727094],
  ["42105","Agustoni","42105010","Localidad simple",-35.7811018772957,-63.3932493460357],
  ["42105","Dorila","42105020","Localidad simple",-35.7763229509013,-63.716840693317],
  ["42105","General Pico","42105030","Localidad simple",-35.6633805937206,-63.760929267739],
  ["42105","Speluzzi","42105040","Localidad simple",-35.5472936217159,-63.8200403343494],
  ["42105","Trebolares","42105050","Localidad simple",-35.5855840986961,-63.5887521403772],
  ["42112","Casa de Piedra","42112005","Localidad simple",-38.2230515311115,-67.1709263654639],
  ["42112","Puelén","42112010","Localidad simple",-37.3400655492208,-67.6218500509991],
  ["42112","25 de Mayo","42112020","Localidad simple",-37.7697053748681,-67.7172958236186],
  ["42119","Colonia Barón","42119010","Localidad simple",-36.1513889624763,-63.8541959060258],
  ["42119","Colonia San José","42119020","Localidad simple",-36.1170514464671,-63.9040708614432],
  ["42119","Miguel Cané","42119030","Localidad simple",-36.1549581794141,-63.5121543730908],
  ["42119","Quemú Quemú","42119040","Localidad simple",-36.053677480752,-63.5632432919432],
  ["42119","Relmo","42119050","Localidad simple",-36.2573837868411,-63.4481302030919],
  ["42119","Villa Mirasol","42119060","Localidad simple",-36.0757513459043,-63.8875837941037],
  ["42126","Caleufú","42126010","Localidad simple",-35.5928646334622,-64.5586842581366],
  ["42126","Ingeniero Foster","42126020","Localidad simple",-35.7014889174834,-65.1025535202338],
  ["42126","La Maruja","42126030","Localidad simple",-35.671688678266,-64.940569826581],
  ["42126","Parera","42126040","Localidad simple",-35.1462930750947,-64.5006491231723],
  ["42126","Pichi Huinca","42126050","Localidad simple",-35.6473423932767,-64.7695280662631],
  ["42126","Quetrequén","42126060","Localidad simple",-35.0548439319725,-64.5213693396742],
  ["42126","Rancul","42126070","Localidad simple",-35.0661985558406,-64.683114985952],
  ["42133","Adolfo Van Praet","42133010","Localidad simple",-35.0179130302315,-64.035117861781],
  ["42133","Alta Italia","42133020","Localidad simple",-35.3338595551664,-64.1182405361085],
  ["42133","Damián Maisonave","42133030","Localidad simple",-35.0415558502239,-64.3847126106129],
  ["42133","Embajador Martini","42133040","Localidad simple",-35.3861854808903,-64.2836857257322],
  ["42133","Falucho","42133050","Localidad simple",-35.1890814426625,-64.1038732251149],
  ["42133","Ingeniero Luiggi","42133060","Localidad simple",-35.3837504384967,-64.4685685991593],
  ["42133","Ojeda","42133070","Localidad simple",-35.3068277686525,-64.0054725550363],
  ["42133","Realicó","42133080","Localidad simple",-35.0368857536117,-64.2454209673953],
  ["42140","Cachirulo","42140005","Localidad simple",-36.7473961516096,-64.3673907018325],
  ["42140","Naicó","42140010","Localidad simple",-36.9283865222889,-64.3952508587586],
  ["42140","Toay","42140020","Componente de localidad compuesta",-36.6751577652887,-64.3803253806581],
  ["42147","Arata","42147010","Localidad simple",-35.6381231858073,-64.3574125644643],
  ["42147","Metileo","42147020","Localidad simple",-35.7732438729278,-63.9428308886673],
  ["42147","Trenel","42147030","Localidad simple",-35.6941743318846,-64.1358999676104],
  ["42154","Ataliva Roca","42154010","Localidad simple",-37.0323315728651,-64.2865724433512],
  ["42154","Colonia Santa María","42154030","Localidad simple",-37.4952435783299,-64.2248805481773],
  ["42154","General Acha","42154040","Localidad simple",-37.373672668717,-64.6038964711256],
  ["42154","Quehué","42154050","Localidad simple",-37.1212005028742,-64.5133661628312],
  ["42154","Unanué","42154060","Localidad simple",-37.5439767222425,-64.3525554864311],
  ["46007","Aimogasta","46007010","Localidad simple",-28.556466715579,-66.8179833262002],
  ["46007","Arauco","46007020","Localidad simple",-28.5834031870202,-66.8036412937626],
  ["46007","Bañado de los Pantanos","46007030","Localidad simple",-28.3871788034279,-66.8369122348367],
  ["46007","Estación Mazán","46007040","Localidad simple",-28.6648262993633,-66.5166195609666],
  ["46007","Termas de Santa Teresita","46007045","Localidad simple",-28.591774966521,-66.5563885931113],
  ["46007","Villa Mazán","46007050","Localidad simple",-28.6586281834455,-66.5552758852995],
  ["46014","La Rioja","46014010","Localidad simple",-29.4217827668094,-66.856675379963],
  ["46021","Aminga","46021010","Localidad simple",-28.8554609845772,-66.9376617661779],
  ["46021","Anillaco","46021020","Localidad simple",-28.8155900262519,-66.9439245714903],
  ["46021","Anjullón","46021030","Localidad simple",-28.7272509428901,-66.9328944677286],
  ["46021","Chuquis","46021040","Localidad simple",-28.8979801822511,-66.9765194957537],
  ["46021","Los Molinos","46021050","Localidad simple",-28.7544152281739,-66.9389202939918],
  ["46021","Pinchas","46021060","Localidad simple",-28.9370760269909,-66.9665171496043],
  ["46021","San Pedro","46021070","Localidad simple",-28.6697090457958,-66.9281338379098],
  ["46021","Santa Vera Cruz","46021080","Localidad simple",-28.6835042192049,-66.9654939868505],
  ["46028","Aicuñá","46028010","Localidad simple",-29.4772470519152,-67.7729134098149],
  ["46028","Guandacol","46028020","Localidad simple",-29.5235988937734,-68.5510416477867],
  ["46028","Los Palacios","46028030","Localidad simple",-29.3713119289112,-68.2271328398885],
  ["46028","Pagancillo","46028040","Localidad simple",-29.5412536132819,-68.0970404734464],
  ["46028","Villa Unión","46028050","Localidad simple",-29.3154179985068,-68.2235171977516],
  ["46035","Chamical","46035010","Localidad simple",-30.3772951613355,-66.3240368838483],
  ["46035","Polco","46035020","Localidad simple",-30.4293153810224,-66.3586422456665],
  ["46042","Chilecito","46042010","Localidad simple",-29.1640818319015,-67.5008066881041],
  ["46042","Colonia Anguinán","46042020","Localidad simple",-29.2540980171571,-67.4261365134089],
  ["46042","Colonia Catinzaco","46042030","Localidad simple",-29.6731660020358,-67.3823669132229],
  ["46042","Colonia Malligasta","46042040","Localidad simple",-29.2029666175252,-67.4003467202303],
  ["46042","Colonia Vichigasta","46042050","Localidad simple",-29.4490716382323,-67.4914198732182],
  ["46042","Guanchín","46042060","Localidad simple",-29.1927256872976,-67.6392754274079],
  ["46042","Malligasta","46042070","Localidad simple",-29.1772024890585,-67.4408316312776],
  ["46042","Miranda","46042080","Localidad simple",-29.3410380679446,-67.6618699588304],
  ["46042","Nonogasta","46042090","Localidad simple",-29.3040959439682,-67.5072784622018],
  ["46042","San Nicolás","46042100","Localidad simple",-29.1217634888802,-67.475895961327],
  ["46042","Santa Florentina","46042110","Localidad simple",-29.1330615805931,-67.5576081781931],
  ["46042","Sañogasta","46042120","Localidad simple",-29.3203738957214,-67.6277959527272],
  ["46042","Tilimuqui","46042130","Localidad simple",-29.1494438672162,-67.4296645756575],
  ["46042","Vichigasta","46042140","Localidad simple",-29.4885973737241,-67.5022852097799],
  ["46049","Alto Carrizal","46049010","Localidad simple",-28.8736691237644,-67.5689979264385],
  ["46049","Angulos","46049020","Localidad simple",-28.6595753462725,-67.6529605556859],
  ["46049","Antinaco","46049030","Localidad simple",-28.8250781693493,-67.3233196534937],
  ["46049","Bajo Carrizal","46049040","Localidad simple",-28.8911007689177,-67.5667461563502],
  ["46049","Campanas","46049050","Localidad simple",-28.5560208289878,-67.6264406513676],
  ["46049","Chañarmuyo","46049060","Localidad simple",-28.6123449106976,-67.5874723425836],
  ["46049","Famatina","46049070","Localidad simple",-28.9291000348798,-67.5207596756721],
  ["46049","La Cuadra","46049080","Localidad simple",-28.4724817643376,-67.6918652569621],
  ["46049","Pituil","46049090","Localidad simple",-28.5815077306519,-67.4508379497994],
  ["46049","Plaza Vieja","46049100","Localidad simple",-28.9731598381662,-67.5201315513043],
  ["46049","Santa Cruz","46049110","Localidad simple",-28.4907371197999,-67.6899252647169],
  ["46049","Santo Domingo","46049120","Localidad simple",-28.5600668428724,-67.6855704208219],
  ["46056","Punta de los Llanos","46056010","Localidad simple",-30.165433857594,-66.556575245663],
  ["46056","Tama","46056020","Localidad simple",-30.5173084388038,-66.5413792482073],
  ["46063","Castro Barros","46063010","Localidad simple",-30.5956924271806,-65.7419372748158],
  ["46063","Chañar","46063020","Localidad simple",-30.5590304532238,-65.97359312056],
  ["46063","Loma Blanca","46063030","Localidad simple",-30.6446137810741,-66.238741686799],
  ["46063","Olta","46063040","Localidad simple",-30.6399759885817,-66.2780604124609],
  ["46070","Malanzán","46070010","Localidad simple",-30.815543887629,-66.6194814951279],
  ["46070","Nácate","46070020","Localidad simple",-30.8640381344546,-66.4051056083956],
  ["46070","Portezuelo","46070030","Localidad simple",-30.847619186484,-66.7186798501751],
  ["46070","San Antonio","46070040","Localidad simple",-31.0900907205412,-66.7571869922571],
  ["46077","Villa Castelli","46077010","Localidad simple",-29.0207515543035,-68.2253713917754],
  ["46084","Ambil","46084010","Localidad simple",-31.1413359277957,-66.3603819377386],
  ["46084","Colonia Ortiz de Ocampo","46084020","Localidad simple",-30.9752909491233,-66.195388379496],
  ["46084","Milagro","46084030","Localidad simple",-31.0131717520523,-65.9882554540382],
  ["46084","Olpas","46084040","Localidad simple",-30.8195242375591,-66.2483100669123],
  ["46084","Santa Rita de Catuna","46084050","Localidad simple",-30.9665198359206,-66.2356607957535],
  ["46091","Ulapes","46091010","Localidad simple",-31.582978877023,-66.2514026305989],
  ["46098","Jagüé","46098010","Localidad simple",-28.6604900543905,-68.3668741365882],
  ["46098","Villa San José de Vinchina","46098020","Localidad simple",-28.7797111463416,-68.2060368408699],
  ["46105","Amaná","46105010","Localidad simple",-30.0611119791655,-67.5084950612514],
  ["46105","Patquía","46105020","Localidad simple",-30.0522114405959,-66.8915886798436],
  ["46112","Chepes","46112010","Localidad simple",-31.3506186314416,-66.6046417930744],
  ["46112","Desiderio Tello","46112020","Localidad simple",-31.2240295500516,-66.3334915975105],
  ["46119","Salicas - San Blas","46119010","Localidad simple",-28.3944162851627,-67.0854614422013],
  ["46126","Villa Sanagasta","46126010","Localidad simple",-29.3064491456943,-67.0414097362521],
  ["50007","Mendoza","50007010","Componente de localidad compuesta",-32.8869689020603,-68.8543075227812],
  ["50014","Bowen","50014010","Localidad simple",-35.0009124317209,-67.5161818289008],
  ["50014","Carmensa","50014020","Localidad simple",-35.144905789879,-67.662955044003],
  ["50014","General Alvear","50014030","Localidad simple",-34.9804694766564,-67.7009950828175],
  ["50014","Los Compartos","50014040","Localidad simple",-34.9792604557582,-67.6590893207424],
  ["50021","Godoy Cruz","50021010","Componente de localidad compuesta",-32.912774732031,-68.8573023658093],
  ["50028","Colonia Segovia","50028010","Localidad simple",-32.8445720739406,-68.7264015008636],
  ["50028","Guaymallén","50028020","Componente de localidad compuesta",-32.8846059966724,-68.822041143923],
  ["50028","La Primavera","50028030","Localidad simple",-32.9212115151732,-68.6797682708562],
  ["50028","Los Corralitos","50028040","Localidad simple",-32.8978664693342,-68.7059893326546],
  ["50028","Puente de Hierro","50028050","Localidad simple",-32.8596996528436,-68.6889630695891],
  ["50035","Ingeniero Giagnoni","50035010","Localidad simple",-33.1247748459194,-68.4208925887498],
  ["50035","Junín","50035020","Localidad simple",-33.1450869905894,-68.4921156012444],
  ["50035","La Colonia","50035030","Componente de localidad compuesta",-33.0927994762934,-68.4874957269843],
  ["50035","Los Barriales","50035040","Localidad simple",-33.1010405156356,-68.5675279714819],
  ["50035","Medrano","50035050","Componente de localidad compuesta",-33.1762912284126,-68.6231695474222],
  ["50035","Phillips","50035060","Localidad simple",-33.2032507142375,-68.3832295478144],
  ["50035","Rodríguez Peña","50035070","Localidad simple",-33.1211519220358,-68.6046800215005],
  ["50042","Desaguadero","50042010","Componente de localidad compuesta",-33.4052265769401,-67.1641664357197],
  ["50042","La Paz","50042020","Localidad simple",-33.4610193184125,-67.5595785270435],
  ["50042","Villa Antigua","50042030","Localidad simple",-33.4645156410531,-67.6055785043576],
  ["50049","Blanco Encalada","50049010","Localidad simple",-33.0355485376289,-69.0065315897085],
  ["50049","Jocolí","50049030","Componente de localidad compuesta",-32.5843190924112,-68.6808088140347],
  ["50049","Las Cuevas","50049040","Localidad simple",-32.8080667698938,-70.0865801080922],
  ["50049","Las Heras","50049050","Componente de localidad compuesta",-32.84908036795,-68.8460355137271],
  ["50049","Los Penitentes","50049060","Localidad simple",-32.8369504266306,-69.853921289708],
  ["50049","Polvaredas","50049080","Localidad simple",-32.8190384814445,-69.7097346552796],
  ["50049","Puente del Inca","50049090","Localidad simple",-32.8198835580194,-69.9250020499226],
  ["50049","Punta de Vacas","50049100","Localidad simple",-32.8488063589156,-69.7763007026824],
  ["50049","Uspallata","50049110","Localidad simple",-32.595534534037,-69.3582053741335],
  ["50056","Barrio Alto del Olvido","50056010","Localidad simple",-32.6727794218396,-68.5922473767644],
  ["50056","Barrio Jocolí II","50056020","Localidad simple",-32.6740793089036,-68.6692696211748],
  ["50056","Barrio La Palmera","50056030","Localidad simple",-32.6969328275291,-68.5506213221533],
  ["50056","Barrio La Pega","50056040","Localidad simple",-32.8128590043094,-68.6835373227478],
  ["50056","Barrio Lagunas de Bartoluzzi","50056050","Localidad simple",-32.6111088672136,-68.5714746331489],
  ["50056","Barrio Los Jarilleros","50056060","Localidad simple",-32.7153965740662,-68.6584021819475],
  ["50056","Barrio Los Olivos","50056070","Localidad simple",-32.6972155730911,-68.3295580099939],
  ["50056","Barrio Virgen del Rosario","50056075","Localidad simple",-32.7027597161507,-68.3124921903406],
  ["50056","Costa de Araujo","50056080","Localidad simple",-32.7568943573314,-68.4085951866641],
  ["50056","El Paramillo","50056090","Localidad simple",-32.7813088245414,-68.5336830930131],
  ["50056","El Vergel","50056100","Localidad simple",-32.7623132216047,-68.6476011792189],
  ["50056","Ingeniero Gustavo André","50056110","Localidad simple",-32.6781612841627,-68.3282636512792],
  ["50056","Jocolí","50056120","Componente de localidad compuesta",-32.6125410510041,-68.6790408967957],
  ["50056","Jocolí Viejo","50056130","Localidad simple",-32.7274623415005,-68.6602319575528],
  ["50056","Las Violetas","50056140","Localidad simple",-32.8208151905733,-68.6164140763718],
  ["50056","3 de Mayo","50056150","Localidad simple",-32.6755279452669,-68.646211303192],
  ["50056","Villa Tulumaya","50056160","Localidad simple",-32.7196142429269,-68.6030438537926],
  ["50063","Agrelo","50063010","Localidad simple",-33.1173844439975,-68.8960235351828],
  ["50063","Barrio Perdriel IV","50063020","Localidad simple",-33.0753282280468,-68.9250404043338],
  ["50063","Cacheuta","50063030","Localidad simple",-33.0367104413315,-69.1159068278817],
  ["50063","Costa Flores","50063040","Localidad simple",-33.0705184504058,-68.9343214868201],
  ["50063","El Carrizal","50063050","Localidad simple",-33.3037433557192,-68.7554951968491],
  ["50063","El Salto","50063060","Localidad simple",-32.9505951182203,-69.290869662361],
  ["50063","Las Compuertas","50063070","Localidad simple",-33.0343953638206,-68.9757201428593],
  ["50063","Las Vegas","50063080","Localidad simple",-33.0086616496676,-69.2784957322078],
  ["50063","Luján de Cuyo","50063090","Componente de localidad compuesta",-33.0339983971284,-68.8883741550889],
  ["50063","Perdriel","50063100","Localidad simple",-33.075612044678,-68.8937832343457],
  ["50063","Potrerillos","50063110","Localidad simple",-32.945486814506,-69.2086449063503],
  ["50063","Ugarteche","50063120","Localidad simple",-33.2109451573216,-68.8972088041994],
  ["50070","Barrancas","50070010","Localidad simple",-33.0833355400244,-68.734379255702],
  ["50070","Barrio Jesús de Nazaret","50070020","Localidad simple",-33.0103244179699,-68.7265920537236],
  ["50070","Cruz de Piedra","50070030","Localidad simple",-33.0293391100097,-68.7922412248266],
  ["50070","El Pedregal","50070040","Localidad simple",-32.8558805014704,-68.6544793531012],
  ["50070","Fray Luis Beltrán","50070050","Localidad simple",-33.0049403047291,-68.6612377129717],
  ["50070","Maipú","50070060","Componente de localidad compuesta",-32.9791481716669,-68.7983205922319],
  ["50070","Rodeo del Medio","50070070","Localidad simple",-32.9880056754694,-68.7010652608485],
  ["50070","Russell","50070080","Localidad simple",-33.0046770772728,-68.8012715093769],
  ["50070","San Roque","50070090","Localidad simple",-33.0285638174611,-68.5981475648442],
  ["50070","Villa Teresa","50070100","Localidad simple",-33.0183178912335,-68.6288154157882],
  ["50077","Agua Escondida","50077010","Localidad simple",-36.1532390359812,-68.3048428543176],
  ["50077","Las Leñas","50077030","Localidad simple",-35.1539650781638,-70.0817910991633],
  ["50077","Malargüe","50077040","Localidad simple",-35.4770107120892,-69.5886491865782],
  ["50084","Andrade","50084010","Localidad simple",-33.1624680014146,-68.506066911759],
  ["50084","Barrio Cooperativa Los Campamentos","50084020","Localidad simple",-33.2692489302548,-68.4383631651486],
  ["50084","Barrio Rivadavia","50084030","Localidad simple",-33.2304643070476,-68.4837256054182],
  ["50084","El Mirador","50084040","Localidad simple",-33.2906467543213,-68.3475556585344],
  ["50084","La Central","50084050","Localidad simple",-33.2736424903476,-68.3224073182181],
  ["50084","La Esperanza","50084060","Localidad simple",-33.3170659709211,-68.3343426790403],
  ["50084","La Florida","50084070","Localidad simple",-33.2686978003988,-68.4637895827175],
  ["50084","La Libertad","50084080","Localidad simple",-33.2163869013321,-68.5166268853637],
  ["50084","Los Árboles","50084090","Localidad simple",-33.1813162523339,-68.5759160345244],
  ["50084","Los Campamentos","50084100","Localidad simple",-33.2763607628549,-68.4008493516637],
  ["50084","Medrano","50084110","Componente de localidad compuesta",-33.1787463382932,-68.6219271508794],
  ["50084","Mundo Nuevo","50084120","Localidad simple",-33.1753415989261,-68.4371725862256],
  ["50084","Reducción de Abajo","50084130","Localidad simple",-33.20630887725,-68.5835152115814],
  ["50084","Rivadavia","50084140","Localidad simple",-33.19403215031,-68.4736188877526],
  ["50084","Santa María de Oro","50084150","Localidad simple",-33.2059806305116,-68.4335589109359],
  ["50091","Barrio Carrasco","50091005","Localidad simple",-33.8321066130502,-69.0490032074461],
  ["50091","Barrio El Cepillo","50091010","Localidad simple",-33.8386533809471,-69.1303497215531],
  ["50091","Chilecito","50091020","Localidad simple",-33.8934020968296,-69.0804633582269],
  ["50091","Eugenio Bustos","50091030","Localidad simple",-33.7850224488547,-69.0729045258216],
  ["50091","La Consulta","50091040","Localidad simple",-33.7386757381913,-69.128125564969],
  ["50091","Pareditas","50091050","Localidad simple",-33.9452563037172,-69.0824859034273],
  ["50091","San Carlos","50091060","Localidad simple",-33.7744494556708,-69.0490909178745],
  ["50098","Alto Verde","50098020","Localidad simple",-33.1195037386563,-68.4180218961221],
  ["50098","Barrio Chivilcoy","50098030","Localidad simple",-33.0411467362082,-68.3541527366296],
  ["50098","Barrio Emanuel","50098040","Localidad simple",-32.8468555962865,-68.4100199226668],
  ["50098","Barrio La Estación","50098045","Localidad simple",-33.155290161095,-68.3543621643557],
  ["50098","Barrio Los Charabones","50098050","Localidad simple",-32.9785115683367,-68.3051018239824],
  ["50098","Barrio Ntra. Sra. De Fátima","50098055","Localidad simple",-33.1309714824443,-68.351277983232],
  ["50098","Chapanay","50098060","Localidad simple",-32.9801177295667,-68.4765253845307],
  ["50098","Chivilcoy","50098070","Localidad simple",-33.038335582925,-68.4594029398777],
  ["50098","El Espino","50098073","Localidad simple",-33.077333062302,-68.3982838200908],
  ["50098","El Ramblón","50098077","Localidad simple",-33.1617709736953,-68.2954844260235],
  ["50098","Montecaseros","50098080","Localidad simple",-33.0109966347898,-68.3936801268914],
  ["50098","Nueva California","50098090","Localidad simple",-32.7450606095364,-68.335450804198],
  ["50098","San Martín","50098100","Componente de localidad compuesta",-33.0857149342167,-68.4809496647904],
  ["50098","Tres Porteñas","50098110","Localidad simple",-32.8994801779561,-68.3990962886724],
  ["50105","Barrio Campos El Toledano","50105010","Localidad simple",-34.573654040475,-68.3294341868083],
  ["50105","Barrio El Nevado","50105020","Localidad simple",-34.7898637210549,-67.9874651693673],
  ["50105","Barrio Empleados de Comercio","50105030","Localidad simple",-34.5522300096664,-68.3032401705615],
  ["50105","Barrio Intendencia","50105040","Localidad simple",-34.645100562517,-68.2754543992411],
  ["50105","Capitán Montoya","50105050","Localidad simple",-34.5835613146883,-68.4654391114406],
  ["50105","Cuadro Benegas","50105060","Localidad simple",-34.6324580327433,-68.4389760704098],
  ["50105","El Nihuil","50105070","Localidad simple",-35.0353713864246,-68.6806149266928],
  ["50105","El Sosneado","50105080","Localidad simple",-35.0821772227253,-69.5924127887533],
  ["50105","El Tropezón","50105090","Localidad simple",-34.6856449091453,-68.2855505604444],
  ["50105","Goudge","50105100","Localidad simple",-34.6803228490363,-68.1358422919666],
  ["50105","Jaime Prats","50105110","Localidad simple",-34.9146831219286,-67.8191470107259],
  ["50105","La Llave Nueva","50105120","Localidad simple",-34.6449297466889,-68.0147704723126],
  ["50105","Las Malvinas","50105130","Localidad simple",-34.8384149976168,-68.2539362219611],
  ["50105","Los Reyunos","50105140","Localidad simple",-34.6099288763693,-68.6205430790631],
  ["50105","Monte Comán","50105150","Localidad simple",-34.5971809945468,-67.8842899055404],
  ["50105","Pobre Diablo","50105160","Localidad simple",-34.6703587937035,-68.3591845637218],
  ["50105","Punta del Agua","50105170","Localidad simple",-35.530165567926,-68.0825092985548],
  ["50105","Rama Caída","50105180","Localidad simple",-34.7043760307316,-68.3708631047738],
  ["50105","Real del Padre","50105190","Localidad simple",-34.8433149755939,-67.7674203749059],
  ["50105","Salto de las Rosas","50105200","Localidad simple",-34.726958284268,-68.2329031579027],
  ["50105","San Rafael","50105210","Localidad simple",-34.6138799163454,-68.3342857455338],
  ["50105","25 de Mayo","50105220","Localidad simple",-34.5859138924719,-68.549568221963],
  ["50105","Villa Atuel","50105230","Localidad simple",-34.8345022006919,-67.9257905889931],
  ["50105","Villa Atuel Norte","50105240","Localidad simple",-34.7605998347691,-68.0374059028042],
  ["50112","Barrio 12 de Octubre","50112010","Localidad simple",-33.1912015360595,-68.2809624398751],
  ["50112","Barrio María Auxiliadora","50112020","Localidad simple",-33.2425136237648,-68.1826758332982],
  ["50112","Barrio Molina Cabrera","50112030","Localidad simple",-33.1297119555186,-68.2037878560507],
  ["50112","La Dormida","50112040","Localidad simple",-33.3499243562079,-67.9160460628593],
  ["50112","Las Catitas","50112050","Localidad simple",-33.3001058785583,-68.0532182373692],
  ["50112","Santa Rosa","50112060","Localidad simple",-33.2544227888887,-68.1567438797332],
  ["50119","Barrio San Cayetano","50119010","Localidad simple",-33.6339135898779,-69.1879023870713],
  ["50119","Campo Los Andes","50119020","Localidad simple",-33.707078744557,-69.1826331369796],
  ["50119","Colonia Las Rosas","50119030","Localidad simple",-33.6129364669521,-69.1126485401012],
  ["50119","El Manzano","50119040","Localidad simple",-33.6005741925646,-69.3350878551814],
  ["50119","Los Sauces","50119050","Localidad simple",-33.5952101670008,-69.1840214848841],
  ["50119","Tunuyán","50119060","Localidad simple",-33.5775549686559,-69.0253759357637],
  ["50119","Vista Flores","50119070","Localidad simple",-33.651355463945,-69.1646922660824],
  ["50126","Barrio Belgrano Norte","50126010","Localidad simple",-33.3301032817585,-69.1359513617454],
  ["50126","Cordón del Plata","50126020","Localidad simple",-33.4689491349532,-69.1399451802858],
  ["50126","El Peral","50126030","Localidad simple",-33.3706550679362,-69.1923487111206],
  ["50126","El Zampal","50126035","Localidad simple",-33.3989500475535,-69.1057367245591],
  ["50126","La Arboleda","50126040","Localidad simple",-33.3688267818118,-69.1247363670469],
  ["50126","San José","50126050","Localidad simple",-33.3068450101282,-69.1645780862147],
  ["50126","Tupungato","50126060","Localidad simple",-33.3715188696073,-69.1570213305004],
  ["54007","Apóstoles","54007010","Localidad simple",-27.909806877888,-55.7532126178863],
  ["54007","Azara","54007020","Localidad simple",-28.057251205305,-55.6767993766976],
  ["54007","Barrio Rural","54007025","Localidad simple",-27.8839188226826,-55.7857809648064],
  ["54007","Estación Apóstoles","54007030","Componente de localidad compuesta",-27.9079594261468,-55.8079584118965],
  ["54007","Pindapoy","54007040","Localidad simple",-27.7474272299697,-55.7932485753782],
  ["54007","Rincón de Azara","54007050","Localidad simple",-28.108077909743,-55.6318879848455],
  ["54007","San José","54007060","Localidad simple",-27.7653179990542,-55.7746920758949],
  ["54007","Tres Capones","54007070","Localidad simple",-28.0000872703207,-55.608042877744],
  ["54014","Aristóbulo del Valle","54014010","Localidad simple",-27.0952902000827,-54.8949054572105],
  ["54014","Campo Grande","54014020","Localidad simple",-27.2062681295066,-54.9790955036689],
  ["54014","Dos de Mayo","54014030","Localidad simple",-27.0205393332885,-54.6877327006159],
  ["54014","Dos de Mayo Nucleo III (Bº Bernardino Rivadavia)","54014050","Localidad simple",-27.0065768537216,-54.6123536244069],
  ["54014","Kilómetro 17","54014055","Localidad simple",-27.3105260940584,-54.9030555649231],
  ["54014","1º de Mayo","54014060","Localidad simple",-27.1660848947707,-55.029165269622],
  ["54014","Pueblo Illia","54014070","Localidad simple",-27.1485153432864,-54.5624940052185],
  ["54014","Salto Encantado","54014080","Localidad simple",-27.0822797871022,-54.8334856092969],
  ["54021","Barrio del Lago","54021005","Localidad simple",-27.4636033945712,-55.8005801049338],
  ["54021","Bonpland","54021010","Localidad simple",-27.4820696887808,-55.4774200837194],
  ["54021","Candelaria","54021020","Localidad simple",-27.4591653471738,-55.7430844145913],
  ["54021","Cerro Corá","54021030","Localidad simple",-27.508609969523,-55.6038621436184],
  ["54021","Loreto","54021040","Localidad simple",-27.3296012279697,-55.5228090005038],
  ["54021","Mártires","54021050","Localidad simple",-27.4188647592881,-55.3777936639947],
  ["54021","Profundidad","54021060","Localidad simple",-27.5585198137316,-55.7034474067364],
  ["54021","Puerto Santa Ana","54021070","Localidad simple",-27.3330798818829,-55.5864347793367],
  ["54021","Santa Ana","54021080","Localidad simple",-27.3671212837411,-55.5805568560225],
  ["54028","Barrio Nuevo Garupa","54028005","Localidad simple",-27.4321009059125,-55.826138545257],
  ["54028","Garupá","54028010","Componente de localidad compuesta",-27.4788128514289,-55.8224411787639],
  ["54028","Nemesio Parma","54028020","Localidad simple",-27.367003658843,-55.9982208456294],
  ["54028","Posadas","54028030","Componente de localidad compuesta",-27.36621704276,-55.8940020980262],
  ["54028","Posadas (Extensión)","54028040","Componente de localidad compuesta",-27.4398084875081,-55.8732093512976],
  ["54035","Barra Concepción","54035010","Localidad simple",-28.1109522025733,-55.5820048143948],
  ["54035","Concepción de la Sierra","54035020","Localidad simple",-27.9813155596218,-55.5209343056682],
  ["54035","La Corita","54035030","Localidad simple",-27.8884115577679,-55.3552996952999],
  ["54035","Santa María","54035040","Localidad simple",-27.9292852570213,-55.4120566457096],
  ["54042","Colonia Victoria","54042010","Localidad simple",-26.3298887730818,-54.6215572258235],
  ["54042","Eldorado","54042020","Localidad simple",-26.4086211746541,-54.6238428075538],
  ["54042","María Magdalena","54042030","Localidad simple",-26.2380924409231,-54.6018096123882],
  ["54042","Nueva Delicia","54042035","Localidad simple",-26.1791395472552,-54.5836572818887],
  ["54042","9 de Julio Kilómetro 28","54042040","Localidad simple",-26.4302810162412,-54.4664666896921],
  ["54042","9 de Julio Kilómetro 20","54042050","Localidad simple",-26.4145333109522,-54.4976116231155],
  ["54042","Pueblo Nuevo","54042055","Localidad simple",-26.2445413608016,-54.5904675610809],
  ["54042","Puerto Mado","54042060","Localidad simple",-26.2310899121585,-54.6247146607981],
  ["54042","Puerto Pinares","54042070","Localidad simple",-26.4268174271826,-54.6857660084128],
  ["54042","Santiago de Liniers","54042080","Localidad simple",-26.3905866143255,-54.3947099277232],
  ["54042","Valle Hermoso","54042090","Localidad simple",-26.382535288747,-54.4652848386631],
  ["54042","Villa Roulet","54042100","Localidad simple",-26.4422594958772,-54.6405734856487],
  ["54049","Comandante Andresito","54049010","Localidad simple",-25.6674361424553,-54.0456434709471],
  ["54049","Bernardo de Irigoyen","54049020","Localidad simple",-26.2546761021203,-53.6472133435976],
  ["54049","Caburei","54049025","Localidad simple",-25.6820367479588,-54.1426092989677],
  ["54049","Dos Hermanas","54049030","Localidad simple",-26.2918653520361,-53.7575832277415],
  ["54049","Integración","54049040","Localidad simple",-25.7724726219691,-53.8522974773476],
  ["54049","Piñalito Norte","54049043","Localidad simple",-25.926985370994,-53.9254399080528],
  ["54049","Puerto Andresito","54049045","Localidad simple",-25.5880676406692,-54.0084915753095],
  ["54049","Puerto Deseado","54049047","Localidad simple",-25.7862399598743,-54.038267293845],
  ["54049","San Antonio","54049050","Localidad simple",-26.0557838105078,-53.7339959536295],
  ["54056","El Soberbio","54056010","Localidad simple",-27.2908601020425,-54.2007777459323],
  ["54056","Fracrán","54056020","Localidad simple",-26.740151400562,-54.3000439575816],
  ["54056","San Vicente","54056030","Localidad simple",-26.9953791755128,-54.4834965149084],
  ["54063","Puerto Esperanza","54063010","Localidad simple",-26.0232970897792,-54.6125092333468],
  ["54063","Puerto Libertad","54063020","Localidad simple",-25.9216713372731,-54.5821209872029],
  ["54063","Puerto Iguazú","54063030","Localidad simple",-25.6010431152667,-54.576736880982],
  ["54063","Villa Cooperativa","54063035","Localidad simple",-25.9359867013889,-54.5384663539082],
  ["54063","Colonia Wanda","54063040","Localidad simple",-25.9713257064178,-54.5610255460818],
  ["54070","Almafuerte","54070010","Localidad simple",-27.5062138362368,-55.4018892063725],
  ["54070","Arroyo del Medio","54070020","Localidad simple",-27.698002675484,-55.4064788856062],
  ["54070","Caá - Yarí","54070030","Localidad simple",-27.4807844367608,-55.2992348104351],
  ["54070","Cerro Azul","54070040","Localidad simple",-27.6310347455951,-55.4938681670811],
  ["54070","Dos Arroyos","54070050","Localidad simple",-27.6941714233049,-55.2587801693628],
  ["54070","Gobernador López","54070060","Localidad simple",-27.6615245708492,-55.2124455595202],
  ["54070","Leandro N. Alem","54070070","Localidad simple",-27.601867604082,-55.3264659218849],
  ["54070","Olegario V. Andrade","54070080","Localidad simple",-27.5658220357689,-55.5017254277441],
  ["54070","Villa Libertad","54070090","Componente de localidad compuesta",-27.5583422242544,-55.3160862221368],
  ["54077","Capioví","54077010","Localidad simple",-26.9292033223206,-55.0569367980451],
  ["54077","Capioviciño","54077015","Localidad simple",-26.8795016704132,-55.0705133852003],
  ["54077","El Alcázar","54077020","Localidad simple",-26.7102586382645,-54.8161444547822],
  ["54077","Garuhapé","54077030","Localidad simple",-26.8186828823083,-54.9576120074302],
  ["54077","Mbopicuá","54077040","Localidad simple",-26.8615012222942,-55.0463438652711],
  ["54077","Puerto Leoni","54077050","Localidad simple",-26.9840910613646,-55.1694842635982],
  ["54077","Puerto Rico","54077060","Localidad simple",-26.8148524027618,-55.0240728847561],
  ["54077","Ruiz de Montoya","54077070","Localidad simple",-26.9665882832067,-55.0575899209499],
  ["54077","San Alberto","54077080","Localidad simple",-26.8048950436231,-54.9881508224082],
  ["54077","San Gotardo","54077090","Localidad simple",-26.9225122221192,-55.1238743204073],
  ["54077","San Miguel","54077100","Localidad simple",-26.8533367010148,-54.8892924101276],
  ["54077","Villa Akerman","54077110","Localidad simple",-26.9412646689407,-55.0957711615406],
  ["54077","Villa Urrutia","54077120","Localidad simple",-26.8462676092826,-54.739753574325],
  ["54084","Barrio Cuatro Bocas","54084003","Localidad simple",-26.5482209436331,-54.6748836684444],
  ["54084","Barrio Guatambu","54084005","Localidad simple",-26.6027932981786,-54.6955807827058],
  ["54084","Bario Ita","54084007","Localidad simple",-26.5283257581417,-54.7089179903484],
  ["54084","Caraguatay","54084010","Localidad simple",-26.6563488324986,-54.7392272649556],
  ["54084","Laharrague","54084020","Localidad simple",-26.532818826907,-54.6506736537237],
  ["54084","Montecarlo","54084030","Localidad simple",-26.5661764915312,-54.7614267394944],
  ["54084","Piray Kilómetro 18","54084040","Localidad simple",-26.5237915925702,-54.5916547620687],
  ["54084","Puerto Piray","54084050","Localidad simple",-26.467494823767,-54.7136760762691],
  ["54084","Tarumá","54084060","Localidad simple",-26.7282097915611,-54.7278209571683],
  ["54084","Villa Parodi","54084070","Localidad simple",-26.4980184491189,-54.6804147225646],
  ["54091","Colonia Alberdi","54091010","Localidad simple",-27.3569655848168,-55.232658571153],
  ["54091","Barrio Escuela 461","54091013","Localidad simple",-27.616902888101,-55.0424750470795],
  ["54091","Barrio Escuela 633","54091017","Localidad simple",-27.4689933468661,-55.0771065017179],
  ["54091","Campo Ramón","54091020","Localidad simple",-27.4522700869441,-55.0237352385306],
  ["54091","Campo Viera","54091030","Localidad simple",-27.3310558767329,-55.0528548158544],
  ["54091","El Salto","54091040","Localidad simple",-27.4917334406126,-55.1989608083666],
  ["54091","General Alvear","54091050","Localidad simple",-27.4228667193793,-55.1702709710526],
  ["54091","Guaraní","54091060","Localidad simple",-27.5203317456103,-55.161363476829],
  ["54091","Los Helechos","54091070","Localidad simple",-27.5531853202103,-55.0778227687919],
  ["54091","Oberá","54091080","Localidad simple",-27.4816559378759,-55.125154693147],
  ["54091","Panambí","54091090","Localidad simple",-27.7185151219435,-54.9183708210206],
  ["54091","Panambí Kilómetro 8","54091100","Localidad simple",-27.6631606292713,-54.9846517202885],
  ["54091","Panambi Kilómetro 15","54091105","Localidad simple",-27.7043305063396,-54.9664319816326],
  ["54091","San Martín","54091110","Localidad simple",-27.4618128955547,-55.2783440740601],
  ["54091","Villa Bonita","54091120","Localidad simple",-27.479699295829,-54.9639234038824],
  ["54098","Barrio Tungoil","54098005","Localidad simple",-27.1077568549388,-55.3881151371992],
  ["54098","Colonia Polana","54098010","Localidad simple",-26.9810475025624,-55.3170685541177],
  ["54098","Corpus","54098020","Localidad simple",-27.1278038790718,-55.5094179289212],
  ["54098","Domingo Savio","54098030","Localidad simple",-27.3546875776242,-55.3368344966029],
  ["54098","General Urquiza","54098040","Localidad simple",-27.1077317789884,-55.3737660823345],
  ["54098","Gobernador Roca","54098050","Localidad simple",-27.1910170928285,-55.4682802860195],
  ["54098","Helvecia","54098060","Localidad simple",-27.110525539393,-55.3438282986148],
  ["54098","Hipólito Yrigoyen","54098070","Localidad simple",-27.0900613258757,-55.2870716950334],
  ["54098","Jardín América","54098080","Localidad simple",-27.0410707861025,-55.2320858824008],
  ["54098","Oasis","54098090","Localidad simple",-26.9708359693882,-55.2491782114282],
  ["54098","Roca Chica","54098100","Localidad simple",-27.2143687134287,-55.4202789802254],
  ["54098","San Ignacio","54098110","Localidad simple",-27.2573496537482,-55.5397360869442],
  ["54098","Santo Pipó","54098120","Localidad simple",-27.1418557045842,-55.4074695445505],
  ["54105","Florentino Ameghino","54105010","Localidad simple",-27.6349575540286,-55.0877551421696],
  ["54105","Itacaruaré","54105020","Localidad simple",-27.8655824463799,-55.2638525290793],
  ["54105","Mojón Grande","54105030","Localidad simple",-27.7077678291473,-55.1582021663853],
  ["54105","San Javier","54105040","Localidad simple",-27.8653231566702,-55.1348376530446],
  ["54112","Cruce Caballero","54112010","Localidad simple",-26.5379470287742,-53.9437324956095],
  ["54112","Paraíso","54112020","Localidad simple",-26.6835663891035,-54.2050107484876],
  ["54112","Piñalito Sur","54112030","Localidad simple",-26.4160781340411,-53.8369134466205],
  ["54112","San Pedro","54112040","Localidad simple",-26.6197903071037,-54.1146818942839],
  ["54112","Tobuna","54112050","Localidad simple",-26.4664417575785,-53.8919888142393],
  ["54119","Alba Posse","54119010","Localidad simple",-27.5641504979908,-54.687011236345],
  ["54119","Alicia Alta","54119020","Localidad simple",-27.3792090956035,-54.3672999680752],
  ["54119","Alicia Baja","54119025","Localidad simple",-27.4285421255892,-54.3575081480921],
  ["54119","Colonia Aurora","54119030","Localidad simple",-27.479557957166,-54.5154356645941],
  ["54119","San Francisco de Asís","54119040","Localidad simple",-27.4597786529494,-54.7478069154214],
  ["54119","Santa Rita","54119050","Localidad simple",-27.5183529379611,-54.7305712624723],
  ["54119","25 de Mayo","54119060","Localidad simple",-27.3715719938072,-54.7475224881518],
  ["58007","Aluminé","58007010","Localidad simple",-39.2395006622098,-70.9180131491473],
  ["58007","Moquehue","58007015","Localidad simple",-38.9431841513779,-71.3282934446594],
  ["58007","Villa Pehuenia","58007020","Localidad simple",-38.88385673767,-71.1721341418285],
  ["58014","Aguada San Roque","58014005","Localidad simple",-37.9994791767967,-68.9231103975687],
  ["58014","Añelo","58014010","Localidad simple",-38.3514440221419,-68.7919715586172],
  ["58014","San Patricio del Chañar","58014020","Localidad simple",-38.6257824069657,-68.2986456816821],
  ["58021","Las Coloradas","58021010","Localidad simple",-39.5578638822685,-70.5932894653763],
  ["58028","Piedra del Águila","58028010","Localidad simple",-40.0465538638605,-70.077319578901],
  ["58028","Santo Tomás","58028020","Localidad simple",-39.8218007278609,-70.1028884849475],
  ["58035","Arroyito","58035010","Localidad simple",-39.0743997961308,-68.5703350642529],
  ["58035","Barrio Ruca Luhé","58035020","Localidad simple",-38.7543907123239,-68.1803399743279],
  ["58035","Centenario","58035030","Localidad simple",-38.8275777081112,-68.1532191639297],
  ["58035","Cutral Có","58035040","Componente de localidad compuesta",-38.9366016135518,-69.2413390332884],
  ["58035","El Chocón","58035050","Localidad simple",-39.2589786425295,-68.8268723660918],
  ["06070","Irineo Portela","06070020","Localidad simple",-33.9810489198561,-59.6715601606315],
  ["58035","Mari Menuco","58035060","Localidad simple",-38.5383043330689,-68.557547832041],
  ["58035","Neuquén","58035070","Componente de localidad compuesta",-38.9492856796033,-68.0839057621977],
  ["58035","11 de Octubre","58035080","Localidad simple",-38.878684024658,-68.1001707201743],
  ["58035","Plaza Huincul","58035090","Componente de localidad compuesta",-38.9290709532125,-69.2021594435231],
  ["58035","Plottier","58035100","Componente de localidad compuesta",-38.9510561611213,-68.2478403865049],
  ["58035","Senillosa","58035110","Localidad simple",-39.0113034801537,-68.4333833911279],
  ["58035","Villa El Chocón","58035120","Localidad simple",-39.2610101785628,-68.7842564223565],
  ["58035","Vista Alegre Norte","58035130","Localidad simple",-38.7277123127679,-68.1721438862367],
  ["58035","Vista Alegre Sur","58035140","Localidad simple",-38.7715537254998,-68.1369187198489],
  ["58042","Chos Malal","58042010","Localidad simple",-37.3792566593514,-70.2723772223192],
  ["58042","Tricao Malal","58042020","Localidad simple",-37.0428490399834,-70.3347175778926],
  ["58042","Villa del Curi Leuvú","58042030","Localidad simple",-37.1337365202591,-70.3969231250344],
  ["58049","Junín de los Andes","58049010","Localidad simple",-39.9494720138355,-71.0703335609136],
  ["58056","San Martín de los Andes","58056010","Localidad simple",-40.1537600653137,-71.3550098619322],
  ["58056","Villa Lago Meliquina","58056020","Localidad simple",-40.3816875508143,-71.2616152793248],
  ["58063","Chorriaca","58063010","Localidad simple",-37.929624048638,-70.0562158162232],
  ["58063","Loncopué","58063020","Localidad simple",-38.0699432722928,-70.6124039046888],
  ["58070","Villa La Angostura","58070010","Localidad simple",-40.7631760692681,-71.6451967512926],
  ["58070","Villa Traful","58070020","Localidad simple",-40.6515336234792,-71.4069733427811],
  ["58077","Andacollo","58077010","Localidad simple",-37.1814100578481,-70.6690765415839],
  ["58077","Huinganco","58077020","Localidad simple",-37.162253742004,-70.6240350766311],
  ["58077","Las Ovejas","58077030","Localidad simple",-36.9881343331798,-70.7487001311443],
  ["58077","Los Miches","58077040","Localidad simple",-37.2079272879053,-70.8208608595818],
  ["58077","Manzano Amargo","58077050","Localidad simple",-36.7475538529054,-70.7652790008941],
  ["58077","Varvarco","58077060","Localidad simple",-36.8575631715293,-70.6784177984493],
  ["58077","Villa del Nahueve","58077070","Localidad simple",-37.1209838887878,-70.7687465935033],
  ["58084","Caviahue","58084010","Localidad simple",-37.8741211534774,-71.0537792468958],
  ["58084","Copahue","58084020","Localidad simple",-37.8191699254756,-71.0991107043764],
  ["58084","El Cholar","58084030","Localidad simple",-37.4408647694624,-70.6441818646861],
  ["58084","El Huecú","58084040","Localidad simple",-37.6415832578483,-70.5790877358744],
  ["58084","Taquimilán","58084050","Localidad simple",-37.5169103878888,-70.2503863712688],
  ["58091","Barrancas","58091010","Localidad simple",-36.8247372962673,-69.9164782914753],
  ["58091","Buta Ranquil","58091020","Localidad simple",-37.0507876062807,-69.873851086363],
  ["58091","Octavio Pico","58091030","Localidad simple",-37.5865104880568,-68.2686075936205],
  ["58091","Rincón de los Sauces","58091040","Localidad simple",-37.3899075901743,-68.9309943279283],
  ["58098","El Sauce","58098005","Localidad simple",-39.4750725824586,-69.5298228549206],
  ["58098","Paso Aguerre","58098010","Localidad simple",-39.3393978445221,-69.8442147950698],
  ["58098","Picún Leufú","58098020","Localidad simple",-39.5191361709356,-69.2962673114558],
  ["58105","Bajada del Agrio","58105010","Localidad simple",-38.4079798578262,-70.0276785984599],
  ["58105","La Buitrera","58105020","Localidad simple",-38.5574702395959,-70.3665560313021],
  ["58105","Las Lajas","58105030","Localidad simple",-38.5292612011937,-70.3689502898327],
  ["58105","Quili Malal","58105040","Localidad simple",-38.3213178634179,-69.8143687558623],
  ["58112","Los Catutos","58112010","Localidad simple",-38.8384807985925,-70.1962106815081],
  ["58112","Mariano Moreno","58112020","Localidad simple",-38.7616758159372,-70.0376761954562],
  ["58112","Ramón M. Castro","58112030","Localidad simple",-38.865500620555,-69.750265287383],
  ["58112","Zapala","58112040","Localidad simple",-38.8961687323721,-70.0668545323772],
  ["62007","El Cóndor","62007020","Localidad simple",-41.043074401021,-62.8212339732456],
  ["62007","El Juncal","62007030","Localidad simple",-40.8040464324129,-63.119258465235],
  ["62007","Guardia Mitre","62007040","Localidad simple",-40.4302951883973,-63.6719140103256],
  ["62007","La Lobería","62007050","Localidad simple",-41.1541008885685,-63.1234800366543],
  ["62007","Loteo Costa de Río","62007060","Localidad simple",-40.8722977227525,-62.9146635826372],
  ["62007","Pozo Salado","62007070","Localidad simple",-41.0178488120515,-64.1403933053127],
  ["62007","San Javier","62007080","Localidad simple",-40.7472509496073,-63.2646524967149],
  ["62007","Viedma","62007090","Componente de localidad compuesta",-40.8093232712389,-62.9853203682712],
  ["62014","Barrio Unión","62014010","Localidad simple",-39.1585373145235,-66.1856066477135],
  ["62014","Chelforó","62014020","Localidad simple",-39.0881631155042,-66.520954661381],
  ["62014","Chimpay","62014030","Localidad simple",-39.1651527318617,-66.1447069274027],
  ["62014","Choele Choel","62014040","Localidad simple",-39.2884543350453,-65.663280823108],
  ["62014","Coronel Belisle","62014050","Localidad simple",-39.1858299915745,-65.9563191181265],
  ["62014","Darwin","62014060","Localidad simple",-39.2026912901608,-65.7409172296959],
  ["62014","Lamarque","62014070","Localidad simple",-39.4232652920959,-65.7014504976777],
  ["62014","Luis Beltrán","62014080","Localidad simple",-39.3088800984468,-65.7648714193881],
  ["62014","Pomona","62014090","Localidad simple",-39.4841604573414,-65.6124600513947],
  ["62021","Arelauquen","62021005","Localidad simple",-41.1700881080441,-71.3851119262238],
  ["62021","Barrio El Pilar","62021010","Localidad simple",-41.1814203033089,-71.3493437707973],
  ["62021","Colonia Suiza","62021020","Localidad simple",-41.0947497360429,-71.505527376881],
  ["62021","El Bolsón","62021030","Localidad simple",-41.9804859657332,-71.5336172136647],
  ["62021","El Foyel","62021040","Localidad simple",-41.6571199223738,-71.4592776287102],
  ["62021","Mallín Ahogado","62021047","Localidad simple",-41.8412736734112,-71.5091292986442],
  ["62021","Río Villegas","62021050","Localidad simple",-41.5822159155763,-71.5012934002795],
  ["62021","San Carlos de Bariloche","62021060","Localidad simple",-41.1369282850916,-71.2990645403112],
  ["62021","Villa Catedral","62021080","Localidad simple",-41.1666351264313,-71.4375745404969],
  ["62021","Villa Los Coihues","62021100","Localidad simple",-41.1575793746786,-71.4131558610974],
  ["62021","Villa Mascardi","62021110","Localidad simple",-41.3495536441427,-71.5090416294131],
  ["62028","Barrio Colonia Conesa","62028010","Localidad simple",-40.1405715071916,-64.3297427915782],
  ["62028","General Conesa","62028020","Localidad simple",-40.1047354258125,-64.452961945825],
  ["62028","Barrio Planta Compresora de Gas","62028030","Localidad simple",-40.05647449244,-64.4726087632632],
  ["62035","Aguada Guzmán","62035010","Localidad simple",-39.9787588388031,-68.8683979876684],
  ["62035","Cerro Policía","62035020","Localidad simple",-39.7252943733893,-68.4939533269128],
  ["62035","El Cuy","62035030","Localidad simple",-39.9230912187031,-68.3369498427779],
  ["62035","Las Perlas","62035040","Localidad simple",-38.9840690690676,-68.1403501822625],
  ["62035","Mencué","62035050","Localidad simple",-40.4229029710507,-69.6143877108253],
  ["62035","Naupa Huen","62035060","Localidad simple",-39.8282845926545,-69.5089726874799],
  ["62035","Paso Córdova","62035070","Componente de localidad compuesta",-39.1153330396607,-67.6264974744394],
  ["62035","Valle Azul","62035080","Localidad simple",-39.1404827453952,-66.7285641693515],
  ["62042","Allen","62042010","Localidad simple",-38.9795106570689,-67.8280213981609],
  ["62042","Paraje Arroyón (Bajo San Cayetano)","62042020","Localidad simple",-38.7513229744845,-68.0085536061591],
  ["62042","Barda del Medio","62042030","Localidad simple",-38.7246633358539,-68.1580560913419],
  ["62042","Barrio Blanco","62042040","Localidad simple",-39.0309641335839,-67.7863228650653],
  ["62042","Barrio Calle Ciega Nº 10","62042050","Localidad simple",-39.0230092190233,-67.8005036132986],
  ["62042","Barrio Calle Ciega Nº 6","62042060","Localidad simple",-39.0430891464152,-67.7520658420811],
  ["62042","Barrio Canale","62042070","Localidad simple",-39.0682963331395,-67.6389236900117],
  ["62042","Barrio Chacra Monte","62042080","Localidad simple",-39.0516494451284,-67.6345853523327],
  ["62042","Barrio Costa Este","62042090","Localidad simple",-39.0418587269805,-67.8075970544366],
  ["62042","Barrio Costa Linda","62042100","Localidad simple",-38.9435967131876,-67.9095130600984],
  ["62042","Barrio Costa Oeste","62042110","Localidad simple",-39.0280740237159,-67.8406950461567],
  ["62042","Barrio Destacamento","62042115","Localidad simple",-37.688801948065,-67.8695487107459],
  ["62042","Barrio El Labrador","62042120","Localidad simple",-38.67192317216,-68.2343296924898],
  ["62042","Barrio El Maruchito","62042130","Localidad simple",-38.9965483470472,-67.7600066651023],
  ["62042","Barrio El Petróleo","62042140","Localidad simple",-39.0639270176593,-67.5120162799717],
  ["62042","Barrio Emergente","62042143","Localidad simple",-39.001652251504,-67.8506842254546],
  ["62042","Barrio Fátima","62042147","Localidad simple",-39.0531680628778,-67.472967428649],
  ["62042","Barrio Frontera","62042150","Localidad simple",-39.071916321907,-67.7129100460388],
  ["62042","Barrio Guerrico","62042160","Localidad simple",-39.0416838101557,-67.7340081423714],
  ["62042","Barrio Isla 10","62042170","Localidad simple",-38.9966443708843,-67.9181463726224],
  ["62042","Barrio La Barda","62042180","Localidad simple",-39.0494648024568,-67.217793659392],
  ["62042","Barrio La Costa","62042190","Localidad simple",-39.0753070627553,-67.5392261916358],
  ["62042","Barrio La Costa","62042200","Localidad simple",-39.0923450479727,-67.2007281871129],
  ["62042","Barrio La Defensa","62042210","Localidad simple",-39.0331815789057,-67.3862477660724],
  ["62042","Barrio La Herradura","62042215","Localidad simple",-39.0370774236916,-67.7820594526763],
  ["62042","Barrio La Ribera - Barrio APYCAR","62042230","Localidad simple",-39.0772588097086,-67.5794991279564],
  ["62042","Puente Cero","62042240","Localidad simple",-39.0298112121202,-67.5009911848666],
  ["62042","Barrio Luisillo","62042245","Localidad simple",-39.0514047890722,-67.3468986066244],
  ["62042","Barrio Mar del Plata","62042250","Localidad simple",-39.0827873095255,-67.6523985545637],
  ["62042","Barrio María Elvira","62042260","Localidad simple",-38.9901442627179,-67.9613095600255],
  ["62042","Barrio Moño Azul","62042265","Localidad simple",-39.1306874014844,-66.8941649716277],
  ["62042","Barrio Mosconi","62042270","Localidad simple",-39.0907183953718,-67.5898603467619],
  ["62042","Barrio Norte","62042280","Componente de localidad compuesta",-38.8637279259728,-68.0231905596235],
  ["62042","Barrio Pinar","62042297","Localidad simple",-37.6748275939008,-67.873652130682],
  ["62042","Barrio Porvenir","62042310","Localidad simple",-39.0430283937958,-67.4642040039168],
  ["62042","Barrio Puente 83","62042330","Localidad simple",-38.9565610907804,-67.9463561564044],
  ["62042","Barrio Santa Lucia","62042335","Localidad simple",-39.0282517975929,-67.2984549123711],
  ["62042","Barrio Santa Rita","62042340","Localidad simple",-39.1260785745275,-67.1035165050666],
  ["62042","Barrio Unión","62042350","Localidad simple",-38.979186876102,-67.941976373184],
  ["62042","Catriel","62042360","Localidad simple",-37.881528862589,-67.7945569701758],
  ["62042","Cervantes","62042370","Localidad simple",-39.0515785846632,-67.3930560378065],
  ["62042","Chichinales","62042380","Localidad simple",-39.1148814347412,-66.9425150029993],
  ["62042","Cinco Saltos","62042390","Localidad simple",-38.8275620197176,-68.06609620552],
  ["62042","Cipolletti","62042400","Localidad simple",-38.924558895075,-68.035384250397],
  ["62042","Contralmirante Cordero","62042410","Localidad simple",-38.7570062611988,-68.0994972104866],
  ["62042","Ferri","62042420","Localidad simple",-38.8871754648156,-68.0068433988189],
  ["62042","General Enrique Godoy","62042430","Localidad simple",-39.0795501222919,-67.1575508259755],
  ["62042","General Fernández Oro","62042440","Localidad simple",-38.95436020459,-67.9251089784988],
  ["62042","General Roca","62042450","Localidad simple",-39.0267025182087,-67.5748540962425],
  ["62042","Ingeniero Luis A. Huergo","62042460","Localidad simple",-39.0711757468082,-67.2328876350348],
  ["62042","Ingeniero Otto Krause","62042470","Localidad simple",-39.1114281023989,-66.9939096262054],
  ["62042","Mainqué","62042480","Localidad simple",-39.0637561999382,-67.3042811813575],
  ["62042","Paso Córdova","62042490","Componente de localidad compuesta",-39.107750409664,-67.6277074998828],
  ["62042","Península Ruca Co","62042500","Localidad simple",-38.7010665100453,-68.0277179698785],
  ["62042","Sargento Vidal","62042520","Localidad simple",-38.6856409614896,-68.1580780282182],
  ["62042","Villa Alberdi","62042530","Localidad simple",-39.1283463654662,-67.0481125141998],
  ["62042","Villa del Parque","62042540","Localidad simple",-39.1258079817539,-66.9976300412367],
  ["62042","Villa Manzano","62042550","Localidad simple",-38.6806041543676,-68.2157180851266],
  ["62042","Villa Regina","62042560","Localidad simple",-39.0962966627004,-67.0828092630939],
  ["62042","Villa San Isidro","62042570","Localidad simple",-38.7064851078187,-68.1737455217996],
  ["62049","Comicó","62049010","Localidad simple",-41.0632755118249,-67.5965600975269],
  ["62049","Cona Niyeu","62049020","Localidad simple",-41.8812021704501,-66.9407404270844],
  ["62049","Ministro Ramos Mexía","62049030","Localidad simple",-40.5085400133825,-67.2619207148835],
  ["62049","Prahuaniyeu","62049040","Localidad simple",-41.3591519247092,-67.9314763422669],
  ["62049","Sierra Colorada","62049050","Localidad simple",-40.5850993527615,-67.7555445864448],
  ["62049","Treneta","62049060","Localidad simple",-40.8508277432449,-66.9816846927042],
  ["62049","Yaminué","62049070","Localidad simple",-40.8429274507991,-67.1922500656909],
  ["62056","Las Bayas","62056010","Localidad simple",-41.4504057812872,-70.6827894626766],
  ["62056","Mamuel Choique","62056020","Localidad simple",-41.7698416427745,-70.1708632216436],
  ["62056","Ñorquincó","62056030","Localidad simple",-41.843448611748,-70.8943932149944],
  ["62056","Ojos de Agua","62056040","Localidad simple",-41.534892227381,-69.854645970072],
  ["62056","Río Chico","62056050","Localidad simple",-41.7167227835394,-70.4710839014635],
  ["62063","Barrio Esperanza","62063005","Localidad simple",-39.041876855319,-63.9985907357656],
  ["62063","Colonia Juliá y Echarren","62063010","Localidad simple",-39.0361229259361,-64.0139390564756],
  ["62063","Juventud Unida","62063013","Localidad simple",-39.0125652171478,-64.0650447267437],
  ["62063","Pichi Mahuida","62063017","Localidad simple",-38.8296136177487,-64.9374198062825],
  ["62063","Río Colorado","62063020","Componente de localidad compuesta",-38.9914136078743,-64.0874682295519],
  ["62063","Salto Andersen","62063060","Localidad simple",-38.8229789232812,-64.8182778708068],
  ["62070","Cañadón Chileno","62070005","Localidad simple",-40.8843058831975,-70.0229634453504],
  ["62070","Comallo","62070010","Localidad simple",-41.0298746753183,-70.269980649853],
  ["62070","Dina Huapi","62070020","Localidad simple",-41.0691934226158,-71.16219332616],
  ["62070","Laguna Blanca","62070030","Localidad simple",-40.7925954846977,-69.8810399581108],
  ["62070","Ñirihuau","62070040","Localidad simple",-41.0885592834836,-71.1369133751581],
  ["62070","Pilcaniyeu","62070060","Localidad simple",-41.1252901833754,-70.7216943906912],
  ["62070","Pilquiniyeu del Limay","62070070","Localidad simple",-40.5448524836234,-70.0532314661515],
  ["62070","Villa Llanquín","62070080","Localidad simple",-40.9239102047089,-71.0338579770764],
  ["62077","El Empalme","62077005","Localidad simple",-40.7066025441789,-65.0030743715644],
  ["62077","Las Grutas","62077010","Localidad simple",-40.806093320236,-65.0847019757487],
  ["62077","Playas Doradas","62077020","Localidad simple",-41.6277486729047,-65.0218925578712],
  ["62077","Puerto San Antonio Este","62077030","Localidad simple",-40.8008815532575,-64.8778974161853],
  ["62077","Punta Colorada","62077040","Localidad simple",-41.6941221979021,-65.0245573411298],
  ["62077","Saco Viejo","62077045","Localidad simple",-40.811004684265,-64.7581129382783],
  ["62077","San Antonio Oeste","62077050","Localidad simple",-40.7312945275013,-64.9552941307172],
  ["62077","Sierra Grande","62077060","Localidad simple",-41.6071863315513,-65.3534017406091],
  ["62084","Aguada Cecilio","62084010","Localidad simple",-40.8478737807916,-65.8393274592303],
  ["62084","Arroyo Los Berros","62084020","Localidad simple",-41.4372536416486,-66.0950773167367],
  ["62084","Arroyo Ventana","62084030","Localidad simple",-41.6653937822188,-66.0860135550914],
  ["62084","Nahuel Niyeu","62084040","Localidad simple",-40.504198321368,-66.5657529968209],
  ["62084","Sierra Pailemán","62084050","Localidad simple",-41.1812714523245,-65.9614292512301],
  ["62084","Valcheta","62084060","Localidad simple",-40.6778617788507,-66.1653261356888],
  ["62091","Aguada de Guerra","62091010","Localidad simple",-41.0639017102391,-68.3843810353051],
  ["62091","Clemente Onelli","62091020","Localidad simple",-41.2448350046555,-70.0342029410145],
  ["62091","Colan Conhue","62091030","Localidad simple",-40.6706084126156,-69.1112545579992],
  ["62091","El Caín","62091040","Localidad simple",-41.8182874251641,-68.0774152377244],
  ["62091","Ingeniero Jacobacci","62091050","Localidad simple",-41.3268134240327,-69.5441263890306],
  ["62091","Los Menucos","62091060","Localidad simple",-40.8451911426273,-68.0832025061278],
  ["62091","Maquinchao","62091070","Localidad simple",-41.2475165638608,-68.7003410687453],
  ["62091","Mina Santa Teresita","62091080","Localidad simple",-40.9343435582627,-69.411658784618],
  ["62091","Pilquiniyeu","62091090","Localidad simple",-41.9083865405739,-68.3424732450183],
  ["66007","Apolinario Saravia","66007010","Localidad simple",-24.4402117565864,-64.0003361370349],
  ["66007","Ceibalito","66007020","Localidad simple",-25.1278603615752,-64.289673505941],
  ["66007","Centro 25 de Junio","66007030","Localidad simple",-24.9773189675124,-63.8698564395643],
  ["66007","Coronel Mollinedo","66007040","Localidad simple",-24.5136418287603,-64.0648836625582],
  ["66007","Coronel Olleros","66007050","Localidad simple",-25.1146923148948,-64.2258664425772],
  ["66007","El Quebrachal","66007060","Localidad simple",-25.3519821824981,-64.0287963887804],
  ["66007","Gaona","66007070","Localidad simple",-25.2581750325612,-64.0470243002426],
  ["66007","General Pizarro","66007080","Localidad simple",-24.2342248497577,-63.9910915395849],
  ["66007","Joaquín V. González","66007090","Localidad simple",-25.1294324707809,-64.1385893694805],
  ["66007","Las Lajitas","66007100","Localidad simple",-24.7331988444238,-64.1994831202005],
  ["66007","Luis Burela","66007110","Localidad simple",-24.397713500488,-63.9961108041489],
  ["66007","Macapillo","66007120","Localidad simple",-25.421569027557,-63.9896049019406],
  ["66007","Nuestra Señora de Talavera","66007130","Localidad simple",-25.481072557645,-63.7880008281707],
  ["66007","Piquete Cabado","66007140","Localidad simple",-24.8260406674686,-64.1855790667322],
  ["66007","Río del Valle","66007150","Localidad simple",-24.6839685116395,-64.2017888257331],
  ["66007","Tolloche","66007160","Localidad simple",-25.5466456710138,-63.5342918601747],
  ["66014","Cachi","66014010","Localidad simple",-25.1201640072396,-66.1679494412162],
  ["66014","Payogasta","66014020","Localidad simple",-25.0489479804199,-66.1027102397315],
  ["66021","Cafayate","66021010","Localidad simple",-26.0765384358548,-65.9862897320293],
  ["66021","Tolombón","66021020","Localidad simple",-26.2029574679842,-65.9467957704698],
  ["66028","Atocha","66028010","Localidad simple",-24.8166716062155,-65.4787180407276],
  ["66028","La Ciénaga y Barrio San Rafael","66028030","Componente de localidad compuesta",-24.8102390773552,-65.4582617852359],
  ["66028","Las Costas","66028040","Localidad simple",-24.7690498139422,-65.4860333610823],
  ["66028","Salta","66028050","Componente de localidad compuesta",-24.7823766403156,-65.4141329991055],
  ["66028","Villa San Lorenzo","66028060","Componente de localidad compuesta",-24.7333009865645,-65.4847891426226],
  ["66035","Cerrillos","66035010","Componente de localidad compuesta",-24.899748268594,-65.4884058419647],
  ["66035","La Merced","66035020","Localidad simple",-24.9660896493444,-65.4895901036815],
  ["66035","San Agustín","66035030","Localidad simple",-24.9967896088099,-65.4377599331623],
  ["66035","Villa Los Álamos - El Congreso - Las Tunas - Los Pinares - Los Olmos","66035040","Componente de localidad compuesta",-24.8630942974132,-65.4594268472934],
  ["66042","Barrio Finca La Maroma","66042003","Localidad simple",-25.1512347050013,-65.4426106862489],
  ["66042","Barrio La Rotonda","66042005","Localidad simple",-25.0825653440585,-65.5369944152078],
  ["66042","Barrio Santa Teresita","66042007","Localidad simple",-25.0370260259242,-65.5726459572587],
  ["66042","Chicoana","66042010","Localidad simple",-25.1056023710125,-65.5368903535961],
  ["66042","El Carril","66042020","Localidad simple",-25.0768547028404,-65.4938473919709],
  ["66049","Campo Santo","66049010","Localidad simple",-24.6839924533229,-65.102855681603],
  ["66049","El Bordo","66049030","Localidad simple",-24.6610743291372,-65.1054298866391],
  ["66049","General Güemes","66049040","Localidad simple",-24.6684436198384,-65.0493527755239],
  ["66056","Aguaray","66056010","Localidad simple",-22.2388143093458,-63.7283889210813],
  ["66056","Campamento Vespucio","66056020","Localidad simple",-22.5800471662206,-63.8523231844895],
  ["66056","Campichuelo","66056030","Localidad simple",-23.1062412034464,-63.9953139246427],
  ["66056","Campo Durán","66056040","Localidad simple",-22.1925191184959,-63.6556166497527],
  ["66056","Capiazuti","66056050","Localidad simple",-22.1673388747523,-63.7086209918975],
  ["66056","Carboncito","66056060","Localidad simple",-23.2595016179972,-63.8026685275305],
  ["66056","Coronel Cornejo","66056070","Localidad simple",-22.736606161274,-63.8212340428558],
  ["66056","Dragones","66056080","Localidad simple",-23.2581867482105,-63.3390555232417],
  ["66056","Embarcación","66056090","Localidad simple",-23.2042135269827,-64.0900817936338],
  ["66056","General Ballivián","66056100","Localidad simple",-22.9276105225425,-63.8522934424036],
  ["66056","General Mosconi","66056110","Localidad simple",-22.5872984531874,-63.807509866284],
  ["66056","Hickman","66056120","Localidad simple",-23.2174884897188,-63.5643624737058],
  ["66056","Misión Chaqueña","66056130","Localidad simple",-23.2761412353834,-63.7361800240654],
  ["66056","Misión El Cruce - El Milagro - El Jardín de San Martín","66056140","Componente de localidad compuesta",-22.5428328625163,-63.7906336772576],
  ["66056","Misión Kilómetro 6","66056150","Localidad simple",-22.5060228278102,-63.7399721901134],
  ["66056","Pacará","66056170","Localidad simple",-22.4452723425454,-63.43543212618],
  ["66056","Padre Lozano","66056180","Localidad simple",-23.215724803759,-63.8426467906727],
  ["66056","Piquirenda","66056190","Localidad simple",-22.3335490812005,-63.7596847135861],
  ["66056","Profesor Salvador Mazza","66056200","Localidad simple",-22.040531221334,-63.6786872238435],
  ["66056","Tartagal","66056220","Componente de localidad compuesta",-22.5098645099451,-63.7970472996098],
  ["66056","Tobantirenda","66056230","Localidad simple",-22.13833247169,-63.7061819675909],
  ["66056","Tranquitas","66056240","Localidad simple",-22.4076174158756,-63.7681399387897],
  ["66063","Guachipas","66063010","Localidad simple",-25.5235484724461,-65.5187644501143],
  ["66070","Iruya","66070010","Localidad simple",-22.7789158765788,-65.2063598136374],
  ["66070","Isla de Cañas","66070020","Localidad simple",-22.8864200252899,-64.6573757192202],
  ["66070","Pueblo Viejo","66070030","Localidad simple",-22.8263430234688,-65.2018356755618],
  ["66077","La Caldera","66077010","Localidad simple",-24.6049486234217,-65.3823377302988],
  ["66077","Vaqueros","66077020","Componente de localidad compuesta",-24.6945211920197,-65.4026944187147],
  ["66084","El Jardín","66084010","Localidad simple",-26.0938834199791,-65.41384156239],
  ["66084","El Tala","66084020","Localidad simple",-26.1208917578309,-65.2873058787689],
  ["66084","La Candelaria","66084030","Localidad simple",-26.0961790089843,-65.0610119525095],
  ["66091","Cobres","66091010","Localidad simple",-23.6391998500842,-66.2684039729565],
  ["66091","La Poma","66091020","Localidad simple",-24.7129010493054,-66.1997385176463],
  ["66098","Ampascachi","66098010","Localidad simple",-25.355455514438,-65.5323044668329],
  ["66098","Cabra Corral","66098020","Localidad simple",-25.290036707535,-65.38778537012],
  ["66098","Coronel Moldes","66098030","Localidad simple",-25.2889404681421,-65.4745373510335],
  ["66098","La Viña","66098040","Localidad simple",-25.4719724619835,-65.5719838890076],
  ["66098","Talapampa","66098050","Localidad simple",-25.5463746287562,-65.5596728817539],
  ["66105","Olacapato","66105010","Localidad simple",-24.1197745515994,-66.7142594000385],
  ["66105","San Antonio de los Cobres","66105020","Localidad simple",-24.2099310029638,-66.315435998094],
  ["66105","Santa Rosa de los Pastos Grandes","66105030","Localidad simple",-24.478105777316,-66.6785400667592],
  ["66105","Tolar Grande","66105040","Localidad simple",-24.5579851944765,-67.4369653675359],
  ["66112","El Galpón","66112010","Localidad simple",-25.3915864503967,-64.6595062933992],
  ["66112","El Tunal","66112020","Localidad simple",-25.2652645771513,-64.4061042227155],
  ["66112","Lumbreras","66112030","Localidad simple",-25.2172575790264,-64.9306861458005],
  ["66112","San José de Metán (Est. Metán)","66112040","Localidad simple",-25.5077205377148,-64.9821245409304],
  ["66112","Metán Viejo","66112050","Localidad simple",-25.5418039517985,-64.9849385087879],
  ["66112","Río Piedras","66112070","Localidad simple",-25.3211818761179,-64.917329424853],
  ["66112","San José de Orquera","66112080","Localidad simple",-25.2783094165373,-64.0850561648465],
  ["66119","La Puerta","66119010","Localidad simple",-25.2804538149509,-66.4508396566503],
  ["66119","Molinos","66119020","Localidad simple",-25.4442432937572,-66.3088500894253],
  ["66119","Seclantás","66119030","Localidad simple",-25.3305099574445,-66.2484466228606],
  ["66126","Aguas Blancas","66126010","Localidad simple",-22.7245611902241,-64.346319220401],
  ["66126","Colonia Santa Rosa","66126020","Localidad simple",-23.3885957203176,-64.4234333229489],
  ["66126","El Tabacal","66126030","Localidad simple",-23.2500270361093,-64.2445058938392],
  ["66126","Hipólito Yrigoyen","66126040","Localidad simple",-23.2382702479068,-64.2718125360107],
  ["66126","Pichanal","66126060","Localidad simple",-23.3133896525098,-64.219751841333],
  ["66126","San Ramón de la Nueva Orán","66126070","Localidad simple",-23.1298138873916,-64.3185884747041],
  ["66126","Urundel","66126080","Localidad simple",-23.5516314679633,-64.3965188048038],
  ["66133","Alto de la Sierra","66133010","Localidad simple",-22.6893772924132,-62.4527756437584],
  ["66133","Capitán Juan Pagé","66133020","Localidad simple",-23.7084876711102,-62.3817949445121],
  ["66133","Coronel Juan Solá","66133030","Localidad simple",-23.4836432078231,-62.8913108733338],
  ["66133","Hito 1","66133035","Localidad simple",-21.9997109682412,-62.8237382800005],
  ["66133","La Unión","66133040","Localidad simple",-23.946204699024,-63.1119727442095],
  ["66133","Los Blancos","66133050","Localidad simple",-23.630147809494,-62.5972373009179],
  ["66133","Pluma de Pato","66133060","Localidad simple",-23.3808426324425,-63.098055649631],
  ["66133","Rivadavia","66133070","Localidad simple",-24.1928479299753,-62.8855846188739],
  ["66133","Santa María","66133080","Localidad simple",-22.1394975256356,-62.8383245890232],
  ["66133","Santa Rosa","66133090","Localidad simple",-24.0763765853123,-63.1236773681358],
  ["66133","Santa Victoria Este","66133100","Localidad simple",-22.2772903307188,-62.7043719454645],
  ["66140","Antillá","66140010","Localidad simple",-26.1367474431656,-64.6079955159401],
  ["66140","Copo Quile","66140020","Localidad simple",-26.0280256948964,-64.6831914609089],
  ["66140","El Naranjo","66140030","Localidad simple",-25.7376092528727,-65.0197887857072],
  ["66140","El Potrero","66140040","Localidad simple",-26.0638952332339,-64.656831424558],
  ["66140","Rosario de la Frontera","66140050","Localidad simple",-25.8088971820865,-64.9840618242783],
  ["66140","San Felipe","66140060","Localidad simple",-25.7231125127283,-64.8260626677768],
  ["66147","Campo Quijano","66147010","Localidad simple",-24.9095603902622,-65.639505025843],
  ["66147","La Merced del Encón","66147015","Localidad simple",-24.8709646124105,-65.5607604731238],
  ["66147","La Silleta","66147020","Localidad simple",-24.8784643256454,-65.5901794974295],
  ["66147","Rosario de Lerma","66147030","Localidad simple",-24.9780005506773,-65.5804316181731],
  ["66154","Angastaco","66154010","Localidad simple",-25.6837320095857,-66.1630084648275],
  ["66154","Animaná","66154020","Localidad simple",-25.9250695350422,-65.9634886394429],
  ["66154","El Barrial","66154030","Localidad simple",-25.9119189620255,-65.9509642786695],
  ["66154","San Carlos","66154040","Localidad simple",-25.8954496537353,-65.9374115460195],
  ["66161","Acoyte","66161010","Localidad simple",-22.2625708057672,-64.9993425915289],
  ["66161","Campo La Cruz","66161020","Localidad simple",-22.4282266803066,-65.1454049664521],
  ["66161","Los Toldos","66161030","Localidad simple",-22.2528953049178,-64.6816676603736],
  ["66161","Nazareno","66161040","Localidad simple",-22.4818544506086,-65.0949733414157],
  ["66161","Poscaya","66161050","Localidad simple",-22.4336266127546,-65.0678957138661],
  ["66161","San Marcos","66161060","Localidad simple",-22.50900544813,-65.1012423839061],
  ["66161","Santa Victoria","66161070","Localidad simple",-22.2294615004585,-64.9503255468472],
  ["70007","El Rincón","70007010","Localidad simple",-31.4480943761331,-68.5425141343624],
  ["70007","Villa General San Martín - Campo Afuera","70007020","Localidad simple",-31.4400713567127,-68.5203874841953],
  ["70014","Las Tapias","70014010","Localidad simple",-31.4084472492778,-68.3999429561259],
  ["70014","Villa El Salvador - Villa Sefair","70014020","Componente de localidad compuesta",-31.4532677076765,-68.4037594959613],
  ["70021","Barreal - Villa Pituil","70021010","Localidad simple",-31.6479546163892,-69.4769267409273],
  ["70021","Calingasta","70021020","Localidad simple",-31.335410441528,-69.4273817834109],
  ["70021","Tamberías","70021030","Localidad simple",-31.46037726198,-69.4229130996946],
  ["70028","San Juan","70028010","Componente de localidad compuesta",-31.5371970378027,-68.5250183173793],
  ["70035","Bermejo","70035010","Localidad simple",-31.5918363542723,-67.6623620492558],
  ["70035","Barrio Justo P. Castro IV","70035015","Localidad simple",-31.6283025583976,-68.3008272782109],
  ["70035","Caucete","70035020","Localidad simple",-31.6514787868907,-68.2821404352408],
  ["70035","El Rincón","70035030","Localidad simple",-31.6648793452851,-68.3211580078388],
  ["70035","Las Talas - Los Médanos","70035040","Localidad simple",-31.5971626238539,-68.2759559226418],
  ["70035","Marayes","70035050","Localidad simple",-31.4776695630337,-67.3093651877693],
  ["70035","Pie de Palo","70035060","Localidad simple",-31.6609347801136,-68.2204015492999],
  ["70035","Vallecito","70035070","Localidad simple",-31.7403744670002,-67.9885245900588],
  ["70035","Villa Independencia","70035080","Localidad simple",-31.6245292071939,-68.3138150331219],
  ["70042","Chimbas","70042010","Componente de localidad compuesta",-31.4931935738869,-68.5335424387439],
  ["70049","Angualasto","70049010","Localidad simple",-30.0536455973497,-69.1717079231376],
  ["70049","Bella Vista","70049020","Localidad simple",-30.4401531794669,-69.2447866603611],
  ["70049","Iglesia","70049030","Localidad simple",-30.4128218913915,-69.2051642049627],
  ["70049","Las Flores","70049040","Localidad simple",-30.3242644504455,-69.2453069928074],
  ["70049","Pismanta","70049050","Localidad simple",-30.2709800462776,-69.2286104874715],
  ["70049","Rodeo","70049060","Localidad simple",-30.2099580541859,-69.1336132382893],
  ["70049","Tudcum","70049070","Localidad simple",-30.1883781131447,-69.2702835946583],
  ["70056","El Médano","70056010","Localidad simple",-30.1293832105379,-68.6791733044186],
  ["70056","Gran China","70056020","Localidad simple",-30.1225273246059,-68.7161999143951],
  ["70056","Mogna","70056040","Localidad simple",-30.6845100664473,-68.3775543569819],
  ["70056","Niquivil","70056050","Localidad simple",-30.4006750071532,-68.6910630973149],
  ["70056","Pampa Vieja","70056060","Localidad simple",-30.209485342383,-68.6912320947139],
  ["70056","San Isidro","70056070","Localidad simple",-30.1488923473271,-68.7044945534412],
  ["70056","San José de Jáchal","70056080","Localidad simple",-30.2427672850044,-68.7454934559357],
  ["70056","Tamberías","70056090","Localidad simple",-30.1822864487075,-68.7277857836372],
  ["70056","Villa Malvinas Argentinas","70056100","Localidad simple",-30.2142413595614,-68.7165558327867],
  ["70056","Villa Mercedes","70056110","Localidad simple",-30.1088721898604,-68.700942918489],
  ["70063","Alto de Sierra","70063010","Componente de localidad compuesta",-31.6038931113545,-68.3793437143666],
  ["70063","Colonia Fiorito","70063020","Localidad simple",-31.5551785871028,-68.4205987445022],
  ["70063","Las Chacritas","70063030","Localidad simple",-31.5936417922213,-68.4077196718124],
  ["70063","9 de Julio","70063040","Localidad simple",-31.669750919971,-68.3900416378963],
  ["70070","Barrio Municipal","70070005","Localidad simple",-31.7523486776689,-68.5597213740804],
  ["70070","Barrio Ruta 40","70070010","Localidad simple",-31.8595308229437,-68.5345166485174],
  ["70070","Carpintería","70070020","Localidad simple",-31.8301409850684,-68.5420989256398],
  ["70070","Las Piedritas","70070025","Localidad simple",-31.629474322189,-68.6080765638159],
  ["70070","Quinto Cuartel","70070030","Localidad simple",-31.6140359426027,-68.6001745092873],
  ["70070","Villa Aberastain - La Rinconada","70070040","Localidad simple",-31.6572021521934,-68.5795216164253],
  ["70070","Villa Barboza - Villa Nacusi","70070050","Componente de localidad compuesta",-31.5920656659803,-68.5395731548903],
  ["70070","Villa Centenario","70070060","Localidad simple",-31.668402703149,-68.5222919302359],
  ["70077","Rawson","70077010","Componente de localidad compuesta",-31.5827214933958,-68.5420838574223],
  ["70077","Villa Bolaños (Médano de Oro)","70077020","Localidad simple",-31.6292970053945,-68.4706676954017],
  ["70084","Rivadavia","70084010","Componente de localidad compuesta",-31.5335200372447,-68.5920689785483],
  ["70091","Barrio Sadop - Bella Vista","70091010","Localidad simple",-31.5367182711489,-68.3955676778174],
  ["70091","Dos Acequias","70091020","Localidad simple",-31.4913855475125,-68.4185298472673],
  ["70091","San Isidro","70091030","Localidad simple",-31.4870993000717,-68.325134344897],
  ["70091","Villa del Salvador","70091040","Componente de localidad compuesta",-31.4639044466924,-68.4095847372199],
  ["70091","Villa Dominguito","70091050","Localidad simple",-31.55912095737,-68.2976446699079],
  ["70091","Villa Don Bosco","70091060","Localidad simple",-31.5518882180598,-68.3390185136148],
  ["70091","Villa San Martín","70091070","Localidad simple",-31.516761980837,-68.3526471246019],
  ["70098","Santa Lucía","70098010","Componente de localidad compuesta",-31.5402073510047,-68.4979845361119],
  ["70105","Cañada Honda","70105010","Localidad simple",-31.9850527438787,-68.5481911385325],
  ["70105","Cienaguita","70105020","Localidad simple",-32.0763381339971,-68.690762577729],
  ["70105","Colonia Fiscal","70105030","Localidad simple",-31.9027437264496,-68.4696588673218],
  ["70105","Divisadero","70105040","Localidad simple",-32.0104984358581,-68.6904861018003],
  ["70105","Guanacache","70105050","Localidad simple",-32.0753813271385,-68.5856950572685],
  ["70105","Las Lagunas","70105060","Localidad simple",-32.0443775419211,-68.3778990229646],
  ["70105","Los Berros","70105070","Localidad simple",-31.9514576383242,-68.6510941298035],
  ["70105","Pedernal","70105080","Localidad simple",-31.9950077029707,-68.7590874861115],
  ["70105","Punta del Médano","70105090","Localidad simple",-31.8946043291143,-68.4183104905607],
  ["70105","Villa Media Agua","70105100","Localidad simple",-31.9810022624945,-68.4270029177237],
  ["70112","Villa Ibáñez","70112010","Localidad simple",-31.4659385111811,-68.7353338028121],
  ["70119","Astica","70119010","Localidad simple",-30.9538850864023,-67.3006351406982],
  ["70119","Balde del Rosario","70119020","Localidad simple",-30.3207151787316,-67.6951969177396],
  ["70119","Chucuma","70119030","Localidad simple",-31.0688861561951,-67.2788289085567],
  ["70119","Los Baldecitos","70119040","Localidad simple",-30.2241888429482,-67.7014210305429],
  ["70119","Usno","70119050","Localidad simple",-30.5640053498102,-67.540327100629],
  ["70119","Villa San Agustín","70119060","Localidad simple",-30.6367084796207,-67.4650598603898],
  ["70126","El Encón","70126010","Localidad simple",-32.2163733476113,-67.793057098676],
  ["70126","Tupelí","70126020","Localidad simple",-31.8390315742989,-68.3573941216943],
  ["70126","Villa Borjas - La Chimbera","70126030","Localidad simple",-31.8100370285162,-68.3291240822485],
  ["70126","Villa El Tango","70126040","Localidad simple",-31.763268918716,-68.2222966354108],
  ["70126","Villa Santa Rosa","70126050","Localidad simple",-31.7448085385712,-68.3142412332522],
  ["70133","Villa Basilio Nievas","70133010","Localidad simple",-31.548546689325,-68.7308162211572],
  ["74007","Candelaria","74007010","Localidad simple",-32.0607491134468,-65.8276913716033],
  ["74007","Leandro N. Alem","74007030","Localidad simple",-32.487221446504,-66.0539126200252],
  ["74007","Luján","74007040","Localidad simple",-32.3660459650745,-65.9425521623483],
  ["74007","Quines","74007050","Localidad simple",-32.2330822365033,-65.8056329969317],
  ["06021","Alberti","06021010","Localidad simple",-35.0330734347841,-60.2806197287099],
  ["74007","San Francisco del Monte de Oro","74007070","Localidad simple",-32.6006392247111,-66.1273702635842],
  ["74014","La Calera","74014010","Localidad simple",-32.8619918957824,-66.8506529764617],
  ["74014","Nogolí","74014020","Localidad simple",-32.9173752831041,-66.3257602058348],
  ["74014","Villa de la Quebrada","74014030","Localidad simple",-33.0161741932683,-66.2920464806382],
  ["74014","Villa General Roca","74014040","Localidad simple",-32.6661925630758,-66.4524010178082],
  ["74021","Carolina","74021010","Localidad simple",-32.8128571637146,-66.0932327577628],
  ["74021","El Trapiche","74021020","Componente de localidad compuesta",-33.1082715280981,-66.063371211902],
  ["74021","Estancia Grande","74021025","Localidad simple",-33.1905465526598,-66.1527985566352],
  ["74021","Fraga","74021030","Localidad simple",-33.502087069887,-65.7926477789763],
  ["74021","La Bajada","74021040","Localidad simple",-33.157161301266,-66.0131877714641],
  ["74021","La Florida","74021050","Localidad simple",-33.1167587248711,-66.0020090018267],
  ["74021","La Toma","74021060","Localidad simple",-33.0544376204479,-65.62269821015],
  ["74021","Riocito","74021070","Localidad simple",-33.0964304439761,-65.990838382791],
  ["74021","Río Grande","74021080","Componente de localidad compuesta",-33.0485046022503,-66.0717543089664],
  ["74021","Saladillo","74021090","Localidad simple",-33.2005664915694,-65.8531363375249],
  ["74028","Concarán","74028010","Localidad simple",-32.5607275180287,-65.2452806076649],
  ["74028","Cortaderas","74028020","Localidad simple",-32.5076504245814,-64.9869655159434],
  ["74028","Naschel","74028030","Localidad simple",-32.9168215937221,-65.3755476812695],
  ["74028","Papagayos","74028040","Localidad simple",-32.6786405437001,-64.9881795223679],
  ["74028","Renca","74028050","Localidad simple",-32.7717680736652,-65.3637605007649],
  ["74028","San Pablo","74028060","Localidad simple",-32.658342389353,-65.3080920411456],
  ["74028","Tilisarao","74028070","Localidad simple",-32.7329281106581,-65.2915274383295],
  ["74028","Villa del Carmen","74028080","Localidad simple",-32.9411267835778,-65.0394664526979],
  ["74028","Villa Larca","74028090","Localidad simple",-32.6175433008771,-64.9809087535547],
  ["74035","Juan Jorba","74035010","Localidad simple",-33.6132806299836,-65.2717502963014],
  ["74035","Juan Llerena","74035020","Localidad simple",-33.2811132563767,-65.6145766804084],
  ["74035","Justo Daract","74035030","Localidad simple",-33.8585834476817,-65.1870408754728],
  ["74035","La Punilla","74035040","Localidad simple",-33.1429537099622,-65.0861306811865],
  ["74035","Lavaisse","74035050","Localidad simple",-33.8221476840744,-65.4237934358157],
  ["74035","Nación Ranquel","74035055","Localidad simple",-34.6086190002894,-65.7348529983919],
  ["74035","San José del Morro","74035060","Localidad simple",-33.2119853031031,-65.4927334484496],
  ["74035","Villa Mercedes","74035070","Localidad simple",-33.6738636408858,-65.4624765290195],
  ["74035","Villa Reynolds","74035080","Localidad simple",-33.722961850163,-65.3814163660133],
  ["74035","Villa Salles","74035090","Localidad simple",-33.84292794921,-65.2147610955176],
  ["74042","Anchorena","74042010","Localidad simple",-35.6746450244219,-65.4244230509371],
  ["74042","Arizona","74042020","Localidad simple",-35.7229145031177,-65.3187210360081],
  ["74042","Bagual","74042030","Localidad simple",-35.1448484513353,-65.5676652450981],
  ["74042","Batavia","74042040","Localidad simple",-34.7755332557226,-65.6862987148176],
  ["74042","Buena Esperanza","74042050","Localidad simple",-34.7582787968944,-65.2503691694475],
  ["74042","Fortín El Patria","74042060","Localidad simple",-34.769756515675,-65.522934517578],
  ["74042","Fortuna","74042070","Localidad simple",-35.1282918635603,-65.3818218917708],
  ["74042","La Maroma","74042080","Localidad simple",-35.2127003045126,-66.3264252245578],
  ["74042","Los Overos","74042090","Localidad simple",-35.8808971047928,-66.4450142548098],
  ["74042","Martín de Loyola","74042100","Localidad simple",-35.7111681131223,-66.3525275844943],
  ["74042","Nahuel Mapá","74042110","Localidad simple",-34.7833678660504,-66.1701498297947],
  ["74042","Navia","74042120","Localidad simple",-34.7726733665409,-66.5862788668642],
  ["74042","Nueva Galia","74042130","Localidad simple",-35.1124747000615,-65.2532109154966],
  ["74042","Unión","74042140","Localidad simple",-35.1549261061197,-65.9424468511458],
  ["74049","Carpintería","74049010","Localidad simple",-32.4102495120789,-65.0113926769819],
  ["74049","Cerro de Oro","74049020","Localidad simple",-32.3851963369856,-64.9859436108737],
  ["74049","Lafinur","74049030","Localidad simple",-32.0621151953791,-65.3496815467824],
  ["74049","Los Cajones","74049040","Localidad simple",-32.0257513048361,-65.3749361476641],
  ["74049","Los Molles","74049050","Localidad simple",-32.4395447509138,-65.0106822684225],
  ["74049","Merlo","74049060","Localidad simple",-32.3425391142336,-65.0141372032908],
  ["74049","Santa Rosa del Conlara","74049070","Localidad simple",-32.3423081509941,-65.2071206614116],
  ["74049","Talita","74049080","Localidad simple",-32.2481203088315,-65.5838734087874],
  ["74056","Alto Pelado","74056010","Localidad simple",-33.8425029072214,-66.1375993056552],
  ["74056","Alto Pencoso","74056020","Localidad simple",-33.4306363842929,-66.9279669116981],
  ["74056","Balde","74056030","Localidad simple",-33.3432695635017,-66.626047423873],
  ["74056","Beazley","74056040","Localidad simple",-33.757734110106,-66.6459600305752],
  ["74056","Cazador","74056050","Localidad simple",-33.8576584773376,-66.3696150667544],
  ["74056","Chosmes","74056060","Localidad simple",-33.3959968949714,-66.7463973832244],
  ["74056","Desaguadero","74056070","Componente de localidad compuesta",-33.4004585255775,-67.148082207766],
  ["74056","El Volcán","74056080","Localidad simple",-33.2512966067626,-66.1877022971966],
  ["74056","Jarilla","74056090","Localidad simple",-33.3986583419719,-67.0274295478726],
  ["74056","Juana Koslay","74056100","Componente de localidad compuesta",-33.2890410607963,-66.2549506651664],
  ["74056","La Punta","74056105","Localidad simple",-33.1816571259341,-66.313607690249],
  ["74056","Mosmota","74056110","Localidad simple",-33.6458915525894,-66.9934495323611],
  ["74056","Potrero de los Funes","74056120","Localidad simple",-33.2187787091432,-66.2307288183005],
  ["74056","Salinas del Bebedero","74056130","Localidad simple",-33.501125039306,-66.6514406177997],
  ["74056","San Jerónimo","74056140","Localidad simple",-33.1383053611749,-66.5166859326585],
  ["74056","San Luis","74056150","Componente de localidad compuesta",-33.3023139659883,-66.3360877357358],
  ["74056","Zanjitas","74056160","Localidad simple",-33.8022746844103,-66.415462549085],
  ["74063","La Vertiente","74063010","Localidad simple",-32.7975027746268,-65.7568974316301],
  ["74063","Las Aguadas","74063020","Localidad simple",-32.3763580460129,-65.5012041382004],
  ["74063","Las Chacras","74063030","Localidad simple",-32.5435132286539,-65.7446386901218],
  ["74063","Las Lagunas","74063040","Localidad simple",-32.6298120296294,-65.551144128608],
  ["74063","Paso Grande","74063050","Localidad simple",-32.8769737284291,-65.6345301522077],
  ["74063","Potrerillo","74063060","Localidad simple",-32.6714012444881,-65.6626272217676],
  ["74063","San Martín","74063070","Localidad simple",-32.4132690463753,-65.6759306690121],
  ["74063","Villa de Praga","74063080","Localidad simple",-32.5339640778182,-65.6477042790939],
  ["78007","Comandante Luis Piedrabuena","78007010","Localidad simple",-49.9859909808201,-68.9130816915927],
  ["78007","Puerto Santa Cruz","78007020","Localidad simple",-50.0171892721878,-68.5248246324655],
  ["78014","Caleta Olivia","78014010","Localidad simple",-46.4459492303195,-67.5251564969847],
  ["78014","Cañadón Seco","78014020","Localidad simple",-46.5588457703439,-67.616856368573],
  ["78014","Fitz Roy","78014030","Localidad simple",-47.0257940308205,-67.2542856564871],
  ["78014","Jaramillo","78014040","Localidad simple",-47.1847032165886,-67.145582198474],
  ["78014","Koluel Kaike","78014050","Localidad simple",-46.7168267498228,-68.2279614588974],
  ["78014","Las Heras","78014060","Localidad simple",-46.5424553787867,-68.9341773229667],
  ["78014","Pico Truncado","78014070","Localidad simple",-46.7938981244061,-67.9575704898943],
  ["78014","Puerto Deseado","78014080","Localidad simple",-47.7514649275066,-65.9012043680085],
  ["78014","Tellier","78014090","Localidad simple",-47.6487686074581,-66.0446356831872],
  ["78021","El Turbio","78021010","Localidad simple",-51.6805338519685,-72.0874860687819],
  ["78021","Julia Dufour","78021020","Localidad simple",-51.5406111767208,-72.2398967258575],
  ["78021","Mina 3","78021030","Localidad simple",-51.5487660455569,-72.2333909775383],
  ["78021","Río Gallegos","78021040","Localidad simple",-51.6214349839165,-69.2290509293744],
  ["78021","Rospentek","78021050","Localidad simple",-51.6639328934924,-72.1426988306974],
  ["78021","28 de Noviembre","78021060","Localidad simple",-51.5787581525544,-72.2080410883792],
  ["78021","Yacimientos Río Turbio","78021070","Localidad simple",-51.5328383738253,-72.3341032077956],
  ["78028","El Calafate","78028010","Localidad simple",-50.3373208485427,-72.2619950698979],
  ["78028","El Chaltén","78028020","Localidad simple",-49.3319731177032,-72.8916267088672],
  ["78028","Tres Lagos","78028030","Localidad simple",-49.5990148275349,-71.4458022416839],
  ["78035","Los Antiguos","78035010","Localidad simple",-46.5487484894558,-71.6274835082657],
  ["78035","Perito Moreno","78035020","Localidad simple",-46.5921416878797,-70.9257278426639],
  ["78042","Puerto San Julián","78042010","Localidad simple",-49.307703595363,-67.7319702926075],
  ["78049","Bajo Caracoles","78049010","Localidad simple",-47.4461490043983,-70.9285155605965],
  ["78049","Gobernador Gregores","78049020","Localidad simple",-48.7521223249696,-70.2442035901869],
  ["78049","Hipólito Yrigoyen","78049030","Localidad simple",-47.5667812360399,-71.7434756314323],
  ["82007","Armstrong","82007010","Localidad simple",-32.7846557002825,-61.605481877095],
  ["82007","Bouquet","82007020","Localidad simple",-32.4247998561473,-61.8903345863257],
  ["82007","Las Parejas","82007030","Localidad simple",-32.6826842550048,-61.5185798347875],
  ["82007","Las Rosas","82007040","Localidad simple",-32.4785768176046,-61.5748036822531],
  ["82007","Montes de Oca","82007050","Localidad simple",-32.567997020224,-61.7680762352029],
  ["82007","Tortugas","82007060","Localidad simple",-32.7482982621557,-61.8203359267394],
  ["82014","Arequito","82014010","Localidad simple",-33.1483008378636,-61.4713349349692],
  ["82014","Arteaga","82014020","Localidad simple",-33.091131115491,-61.7917113876172],
  ["82014","Beravebú","82014030","Localidad simple",-33.3414152210784,-61.8622809808056],
  ["82014","Bigand","82014040","Localidad simple",-33.3761183026397,-61.185501310201],
  ["82014","Casilda","82014050","Localidad simple",-33.0424955546762,-61.169331118442],
  ["06021","Coronel Seguí","06021020","Localidad simple",-34.8681189984321,-60.3939708823403],
  ["82014","Chabas","82014060","Localidad simple",-33.2470674643201,-61.3575935561826],
  ["82014","Chañar Ladeado","82014070","Localidad simple",-33.3258409849243,-62.0386496702618],
  ["82014","Gödeken","82014080","Localidad simple",-33.402405547162,-61.8449306727075],
  ["82014","Los Molinos","82014090","Localidad simple",-33.1054899954916,-61.3265015329286],
  ["82014","Los Nogales","82014100","Localidad simple",-33.1430061971603,-61.6066128669784],
  ["82014","Los Quirquinchos","82014110","Localidad simple",-33.3769918276119,-61.7121943064881],
  ["82014","San José de la Esquina","82014120","Localidad simple",-33.1140485294151,-61.703312346428],
  ["82014","Sanford","82014130","Localidad simple",-33.1477729818051,-61.2778572887319],
  ["82014","Villada","82014140","Localidad simple",-33.3503085722913,-61.4460374000461],
  ["82021","Aldao","82021010","Localidad simple",-30.9823474545911,-61.7439869348366],
  ["82021","Angélica","82021020","Localidad simple",-31.5526328296108,-61.5462650173096],
  ["82021","Ataliva","82021030","Localidad simple",-30.9981187823937,-61.4325186889204],
  ["82021","Aurelia","82021040","Localidad simple",-31.4236023757354,-61.4244708809147],
  ["82021","Barrios Acapulco y Veracruz","82021050","Componente de localidad compuesta",-31.4192515021464,-62.059146376237],
  ["82021","Bauer y Sigel","82021060","Localidad simple",-31.2731232182116,-61.9448854961657],
  ["82021","Bella Italia","82021070","Localidad simple",-31.2839795053037,-61.409342518123],
  ["82021","Castellanos","82021080","Componente de localidad compuesta",-31.2085396563705,-61.7255955564221],
  ["82021","Colonia Bicha","82021090","Localidad simple",-30.855781133807,-61.8509147420168],
  ["82021","Colonia Cello","82021100","Localidad simple",-31.4338497252165,-61.8417021711297],
  ["82021","Colonia Margarita","82021110","Localidad simple",-31.6868334221829,-61.6492968757313],
  ["82021","Colonia Raquel","82021120","Localidad simple",-30.8392235567556,-61.4897111638226],
  ["82021","Coronel Fraga","82021130","Localidad simple",-31.176158616875,-61.9194620018005],
  ["82021","Egusquiza","82021140","Localidad simple",-31.0976247472919,-61.6283124096054],
  ["82021","Esmeralda","82021150","Localidad simple",-31.6178586482318,-61.9329258733186],
  ["82021","Estación Clucellas","82021160","Localidad simple",-31.52416914925,-61.7206457133884],
  ["82021","Estación Saguier","82021170","Localidad simple",-31.3174603823906,-61.6940034650797],
  ["82021","Eusebia y Carolina","82021180","Localidad simple",-30.9476135702694,-61.8577735272139],
  ["82021","Eustolia","82021190","Localidad simple",-31.5777448514157,-61.7836661825715],
  ["82021","Frontera","82021200","Componente de localidad compuesta",-31.4313990849769,-62.0634917387842],
  ["82021","Garibaldi","82021210","Localidad simple",-31.652027726261,-61.8053907511433],
  ["82021","Humberto Primo","82021220","Localidad simple",-30.8702088524931,-61.3485902390711],
  ["82021","Josefina","82021230","Localidad simple",-31.4079691369305,-61.9921847239399],
  ["82021","Lehmann","82021240","Localidad simple",-31.1272471029986,-61.4529569120506],
  ["82021","María Juana","82021250","Localidad simple",-31.676627573626,-61.7536009774385],
  ["82021","Nueva Lehmann","82021260","Localidad simple",-31.1189046819859,-61.5151982929847],
  ["82021","Plaza Clucellas","82021270","Localidad simple",-31.4545505198837,-61.7074756228147],
  ["82021","Plaza Saguier","82021280","Localidad simple",-31.3251049515902,-61.6777373324018],
  ["82021","Presidente Roca","82021290","Localidad simple",-31.2139896286991,-61.6142352631829],
  ["82021","Pueblo Marini","82021300","Localidad simple",-31.0409745475723,-61.8898826370338],
  ["82021","Rafaela","82021310","Localidad simple",-31.2482482413204,-61.4998117939867],
  ["82021","Ramona","82021320","Localidad simple",-31.0937041766842,-61.9032318673573],
  ["82021","San Antonio","82021330","Componente de localidad compuesta",-31.2128134181244,-61.7257200007794],
  ["82021","San Vicente","82021340","Localidad simple",-31.6999505604131,-61.5688417180763],
  ["82021","Santa Clara de Saguier","82021350","Localidad simple",-31.337359049521,-61.8181783780784],
  ["82021","Sunchales","82021360","Localidad simple",-30.9468555127161,-61.5612504315515],
  ["82021","Susana","82021370","Localidad simple",-31.3575963913649,-61.5164389963223],
  ["82021","Tacural","82021380","Localidad simple",-30.8481071493852,-61.5924018154956],
  ["82021","Vila","82021390","Localidad simple",-31.1923707919052,-61.8336140985666],
  ["82021","Villa Josefina","82021400","Localidad simple",-31.4418599622731,-62.0297169711427],
  ["82021","Villa San José","82021410","Localidad simple",-31.3391346339244,-61.622588386296],
  ["82021","Virginia","82021420","Localidad simple",-30.7402529602428,-61.3409665931228],
  ["82021","Zenón Pereyra","82021430","Localidad simple",-31.5643972137494,-61.898425060781],
  ["82028","Alcorta","82028010","Localidad simple",-33.5401979791092,-61.1246337163914],
  ["82028","Barrio Arroyo del Medio","82028020","Componente de localidad compuesta",-33.2860666179194,-60.2720977056001],
  ["82028","Barrio Mitre","82028030","Componente de localidad compuesta",-33.255594638469,-60.3897758707887],
  ["82028","Bombal","82028040","Localidad simple",-33.4600615218579,-61.3189324391797],
  ["82028","Cañada Rica","82028050","Localidad simple",-33.5174175561246,-60.6132968867711],
  ["82028","Cepeda","82028060","Localidad simple",-33.3984208661427,-60.6241114199013],
  ["82028","Empalme Villa Constitución","82028070","Componente de localidad compuesta",-33.2628625471248,-60.3804644639294],
  ["82028","Firmat","82028080","Componente de localidad compuesta",-33.441023527734,-61.473143421839],
  ["82028","General Gelly","82028090","Localidad simple",-33.6018434911159,-60.5989383522421],
  ["82028","Godoy","82028100","Localidad simple",-33.3697098731789,-60.5094130215383],
  ["82028","Juan B. Molina","82028110","Localidad simple",-33.496020689866,-60.5122133295946],
  ["82028","Juncal","82028120","Localidad simple",-33.71761494002,-61.0500179215707],
  ["82028","La Vanguardia","82028130","Localidad simple",-33.3596257970974,-60.6584568664422],
  ["82028","Máximo Paz","82028140","Localidad simple",-33.4851439474937,-60.9567885809825],
  ["82028","Pavón","82028150","Localidad simple",-33.2430754805422,-60.4062757935089],
  ["82028","Pavón Arriba","82028160","Localidad simple",-33.3134173933438,-60.8249758944661],
  ["82028","Peyrano","82028170","Localidad simple",-33.5411378598405,-60.804329558703],
  ["82028","Rueda","82028180","Localidad simple",-33.335855095367,-60.4608740548372],
  ["82028","Santa Teresa","82028190","Localidad simple",-33.4385471621789,-60.7911542772276],
  ["82028","Sargento Cabral","82028200","Localidad simple",-33.4330128597834,-60.6301906902003],
  ["82028","Stephenson","82028210","Localidad simple",-33.4178567628002,-60.5572137324943],
  ["82028","Theobald","82028220","Localidad simple",-33.3122172562755,-60.3120513587534],
  ["82028","Villa Constitución","82028230","Localidad simple",-33.2324133911798,-60.3324988273466],
  ["82035","Cayastá","82035010","Localidad simple",-31.2023253009306,-60.1614504193394],
  ["82035","Helvecia","82035020","Localidad simple",-31.0992706781177,-60.0881512872483],
  ["82035","Los Zapallos","82035030","Localidad simple",-31.4956365531425,-60.4286467714748],
  ["82035","Saladero Mariano Cabal","82035040","Localidad simple",-30.9229849971234,-60.0481154588667],
  ["82035","Santa Rosa de Calchines","82035050","Localidad simple",-31.422365592266,-60.3348940800468],
  ["82042","Aarón Castellanos","82042010","Localidad simple",-34.3345323396045,-62.3748007656351],
  ["82042","Amenábar","82042020","Localidad simple",-34.136118440775,-62.4229084851078],
  ["82042","Cafferata","82042030","Localidad simple",-33.4414158758935,-62.0868714692657],
  ["82042","Cañada del Ucle","82042040","Localidad simple",-33.4103440716357,-61.6070433975612],
  ["82042","Carmen","82042050","Localidad simple",-33.7327788629688,-61.7609271479418],
  ["82042","Carreras","82042060","Localidad simple",-33.5982834566103,-61.3117684362059],
  ["82042","Chapuy","82042070","Localidad simple",-33.8005299368969,-61.744018193685],
  ["82042","Chovet","82042080","Localidad simple",-33.6007825133126,-61.6046646604986],
  ["82042","Christophersen","82042090","Localidad simple",-34.1846191181657,-62.0235323680591],
  ["82042","Diego de Alvear","82042100","Localidad simple",-34.3743429234538,-62.1289273623308],
  ["82042","Elortondo","82042110","Localidad simple",-33.7016560168056,-61.6163727056605],
  ["82042","Firmat","82042120","Componente de localidad compuesta",-33.4580496833225,-61.4914525089409],
  ["82042","Hughes","82042130","Localidad simple",-33.8028556653324,-61.3358033222625],
  ["82042","La Chispa","82042140","Localidad simple",-33.5446704008321,-61.9736324283311],
  ["82042","Labordeboy","82042150","Localidad simple",-33.7196527453715,-61.3149208168028],
  ["82042","Lazzarino","82042160","Localidad simple",-34.1663295663381,-62.428038027595],
  ["82042","Maggiolo","82042170","Localidad simple",-33.7244236308417,-62.2478391856324],
  ["82042","María Teresa","82042180","Localidad simple",-34.0062849828557,-61.900439675435],
  ["82042","Melincué","82042190","Localidad simple",-33.6619144262235,-61.4576887408087],
  ["82042","Miguel Torres","82042200","Localidad simple",-33.5299502620402,-61.4662068731283],
  ["82042","Murphy","82042210","Localidad simple",-33.6428623685969,-61.8577974691015],
  ["82042","Rufino","82042220","Localidad simple",-34.2636098414032,-62.7117038844931],
  ["82042","San Eduardo","82042230","Localidad simple",-33.8723970130663,-62.0917158307713],
  ["82042","San Francisco de Santa Fe","82042240","Localidad simple",-33.5905400040189,-62.1244693933143],
  ["82042","San Gregorio","82042250","Localidad simple",-34.3265186547551,-62.0379529693876],
  ["82042","Sancti Spiritu","82042260","Localidad simple",-34.0095285599362,-62.2424503438155],
  ["82042","Santa Isabel","82042270","Localidad simple",-33.8894892658382,-61.6965906556385],
  ["82042","Teodelina","82042280","Localidad simple",-34.1916130913817,-61.5272264570788],
  ["82042","Venado Tuerto","82042290","Localidad simple",-33.747315292187,-61.9695358692001],
  ["82042","Villa Cañás","82042300","Localidad simple",-34.0061339956012,-61.6063880455097],
  ["82042","Wheelwright","82042310","Localidad simple",-33.7942942799185,-61.2114409469748],
  ["82049","Arroyo Ceibal","82049010","Localidad simple",-28.7250869970621,-59.4804164807602],
  ["82049","Avellaneda","82049020","Componente de localidad compuesta",-29.1193659780886,-59.6592512444638],
  ["82049","Berna","82049030","Localidad simple",-29.2752681077911,-59.8472221836471],
  ["82049","El Araza","82049040","Localidad simple",-29.1334936783763,-59.9473145917686],
  ["82049","El Rabón","82049050","Localidad simple",-28.2302084157377,-59.2639844821106],
  ["82049","Florencia","82049060","Localidad simple",-28.0427359947317,-59.2187469070082],
  ["82049","Guadalupe Norte","82049070","Localidad simple",-28.9453022044499,-59.5634151929235],
  ["82049","Ingeniero Chanourdie","82049080","Localidad simple",-28.759813885955,-59.5772324985847],
  ["82049","La Isleta","82049090","Localidad simple",-28.493935731005,-59.2950745667521],
  ["82049","La Sarita","82049100","Localidad simple",-28.9728525913241,-59.8484991818248],
  ["82049","Lanteri","82049110","Localidad simple",-28.8429706211446,-59.6379287718138],
  ["82049","Las Garzas","82049120","Localidad simple",-28.8490101824631,-59.5005781021303],
  ["82049","Las Toscas","82049130","Localidad simple",-28.3540749299597,-59.2595521000375],
  ["82049","Los Laureles","82049140","Localidad simple",-29.3701211027814,-59.7378677770758],
  ["82049","Malabrigo","82049150","Localidad simple",-29.3506755184495,-59.9705883109423],
  ["82049","Paraje San Manuel","82049160","Localidad simple",-28.8716623885107,-59.86560439575],
  ["82049","Puerto Reconquista","82049170","Localidad simple",-29.2349873699001,-59.5802691789886],
  ["82049","Reconquista","82049180","Componente de localidad compuesta",-29.1451468389263,-59.6510730563582],
  ["82049","San Antonio de Obligado","82049190","Localidad simple",-28.3823470938865,-59.2645742897512],
  ["82049","Tacuarendí","82049200","Localidad simple",-28.4202062467088,-59.2556740044459],
  ["82049","Villa Ana","82049210","Localidad simple",-28.4933207178133,-59.6141214862397],
  ["82049","Villa Guillermina","82049220","Localidad simple",-28.2450754331528,-59.4547598305134],
  ["82049","Villa Ocampo","82049230","Localidad simple",-28.4904509578913,-59.3587641281681],
  ["82056","Barrio Cicarelli","82056010","Localidad simple",-32.6103776107001,-61.3244409322018],
  ["82056","Bustinza","82056020","Localidad simple",-32.7399961772877,-61.2915869736645],
  ["82056","Cañada de Gómez","82056030","Localidad simple",-32.8166867292145,-61.3899661468272],
  ["82056","Carrizales","82056040","Localidad simple",-32.5112871642714,-61.0305147885477],
  ["82056","Classon","82056050","Localidad simple",-32.4634203095763,-61.2910434085442],
  ["82056","Colonia Médici","82056060","Localidad simple",-32.5988903254118,-61.37671216703],
  ["82056","Correa","82056070","Localidad simple",-32.8494610803638,-61.2545569082818],
  ["82056","Larguía","82056080","Localidad simple",-32.5539810535705,-61.2197995428986],
  ["82056","Lucio V. López","82056090","Localidad simple",-32.7147297231149,-61.0226073568773],
  ["82056","Oliveros","82056100","Localidad simple",-32.5758215248523,-60.8553515331513],
  ["82056","Pueblo Andino","82056110","Localidad simple",-32.6717914164971,-60.8761806736397],
  ["82056","Salto Grande","82056120","Localidad simple",-32.6680220468782,-61.0890486524519],
  ["82056","Serodino","82056130","Localidad simple",-32.6055740792488,-60.9481762653391],
  ["82056","Totoras","82056140","Localidad simple",-32.5863515505869,-61.1673292562769],
  ["82056","Villa Eloísa","82056150","Localidad simple",-32.9643241574442,-61.5478333256653],
  ["82056","Villa La Rivera (Oliveros)","82056160","Componente de localidad compuesta",-32.633431229414,-60.8208776739619],
  ["82056","Villa La Rivera (Pueblo Andino)","82056170","Componente de localidad compuesta",-32.6413858836004,-60.8234183677953],
  ["82063","Angel Gallardo","82063010","Localidad simple",-31.5551884917333,-60.6783108244693],
  ["82063","Arroyo Aguiar","82063020","Localidad simple",-31.4322203707863,-60.6676588774069],
  ["82063","Arroyo Leyes","82063030","Componente de localidad compuesta",-31.5590625698451,-60.517625494979],
  ["82063","Cabal","82063040","Localidad simple",-31.1039907773825,-60.7271526484511],
  ["82063","Campo Andino","82063050","Localidad simple",-31.2410698890417,-60.531189241674],
  ["82063","Candioti","82063060","Localidad simple",-31.3995244031815,-60.7491149288676],
  ["82063","Emilia","82063070","Localidad simple",-31.0610951750412,-60.7464379477764],
  ["82063","Laguna Paiva","82063080","Localidad simple",-31.3092619266382,-60.6607816085928],
  ["82063","Llambi Campbell","82063090","Localidad simple",-31.1862574038904,-60.7484785939749],
  ["82063","Monte Vera","82063100","Localidad simple",-31.5184864327594,-60.6780997937426],
  ["82063","Nelson","82063110","Localidad simple",-31.2670754515364,-60.7621355398528],
  ["82063","Paraje Chaco Chico","82063120","Localidad simple",-31.567299963712,-60.6617466185791],
  ["82063","Paraje La Costa","82063130","Localidad simple",-31.5177974435199,-60.6115160069236],
  ["82063","Recreo","82063140","Componente de localidad compuesta",-31.4935807560402,-60.7354110887079],
  ["82063","Rincón Potrero","82063150","Localidad simple",-31.5286179375841,-60.4756662346225],
  ["82063","San José del Rincón","82063160","Componente de localidad compuesta",-31.6061471114691,-60.569631684875],
  ["82063","Santa Fe","82063170","Componente de localidad compuesta",-31.645164805431,-60.7093147118987],
  ["82063","Santo Tomé","82063180","Componente de localidad compuesta",-31.6648423299398,-60.7626399841519],
  ["82063","Sauce Viejo","82063190","Componente de localidad compuesta",-31.7730250739541,-60.8379697205229],
  ["82063","Villa Laura","82063200","Localidad simple",-31.3738964582973,-60.6647175794109],
  ["82070","Cavour","82070010","Localidad simple",-31.3666330323604,-61.0172254853248],
  ["82070","Cululú","82070020","Localidad simple",-31.2053110846325,-60.9314003415917],
  ["82070","Elisa","82070030","Localidad simple",-30.6980797094537,-61.0487593646417],
  ["82070","Empalme San Carlos","82070040","Localidad simple",-31.5487780871674,-60.8127223355579],
  ["82070","Esperanza","82070050","Localidad simple",-31.4505966144136,-60.9310068119638],
  ["82070","Felicia","82070060","Localidad simple",-31.2463939879149,-61.2128816673977],
  ["82070","Franck","82070070","Localidad simple",-31.5888736174502,-60.938894583032],
  ["82070","Grutly","82070080","Localidad simple",-31.2705026899597,-61.0727542695818],
  ["82070","Hipatía","82070090","Localidad simple",-31.1282518725208,-61.0327676754247],
  ["82070","Humboldt","82070100","Localidad simple",-31.4009210645041,-61.0825515659905],
  ["82070","Jacinto L. Aráuz","82070110","Localidad simple",-30.7370340516557,-60.9759511253175],
  ["82070","La Pelada","82070120","Localidad simple",-30.8679477693336,-60.9718116807155],
  ["82070","Las Tunas","82070130","Localidad simple",-31.5722370638802,-60.9959287992772],
  ["82070","María Luisa","82070140","Localidad simple",-31.0126440481519,-60.9114327492504],
  ["82070","Matilde","82070150","Localidad simple",-31.7932160880623,-60.9818059784844],
  ["82070","Nuevo Torino","82070160","Localidad simple",-31.3468823835409,-61.235725734005],
  ["82070","Pilar","82070170","Localidad simple",-31.442015817123,-61.2600249614063],
  ["82070","Plaza Matilde","82070180","Localidad simple",-31.7974834888763,-61.0111678232689],
  ["82070","Progreso","82070190","Localidad simple",-31.1397689545802,-60.990254156931],
  ["82070","Providencia","82070200","Localidad simple",-30.9845868369063,-61.0218281498813],
  ["82070","Sa Pereyra","82070210","Localidad simple",-31.5721513951563,-61.3782231110791],
  ["82070","San Agustín","82070220","Localidad simple",-31.6847778866246,-60.9413147450231],
  ["82070","San Carlos Centro","82070230","Componente de localidad compuesta",-31.7284179989089,-61.0913957859145],
  ["82070","San Carlos Norte","82070240","Localidad simple",-31.6743105766747,-61.0762585195433],
  ["82070","San Carlos Sud","82070250","Componente de localidad compuesta",-31.7575954064363,-61.1007514980913],
  ["82070","San Jerónimo del Sauce","82070260","Localidad simple",-31.6112124759047,-61.1425180717315],
  ["82070","San Jerónimo Norte","82070270","Localidad simple",-31.5545316682675,-61.078514153956],
  ["82070","San Mariano","82070280","Localidad simple",-31.6702105890861,-61.3480211476448],
  ["82070","Santa Clara de Buena Vista","82070290","Localidad simple",-31.7657963305203,-61.3210236384566],
  ["82070","Santo Domingo","82070300","Localidad simple",-31.1222768363914,-60.8888854567848],
  ["82070","Sarmiento","82070310","Localidad simple",-31.0606024884219,-61.167889729979],
  ["82077","Esteban Rams","82077010","Localidad simple",-29.7726717957721,-61.4881512346811],
  ["82077","Gato Colorado","82077020","Localidad simple",-28.0245785095892,-61.1879373297868],
  ["82077","Gregoria Pérez de Denis","82077030","Localidad simple",-28.2296230607257,-61.5297529930521],
  ["82077","Logroño","82077040","Localidad simple",-29.5042812797874,-61.6967327802837],
  ["82077","Montefiore","82077050","Localidad simple",-29.6678698226711,-61.867108287483],
  ["82077","Pozo Borrado","82077060","Localidad simple",-28.939942303118,-61.7055999743386],
  ["82077","San Bernardo","82077065","Localidad simple",-28.6300342810186,-61.5069219893981],
  ["82077","Santa Margarita","82077070","Localidad simple",-28.3149549140447,-61.5503299373549],
  ["82077","Tostado","82077080","Localidad simple",-29.2344732488739,-61.7719824163622],
  ["82077","Villa Minetti","82077090","Localidad simple",-28.6247095403571,-61.6279859869967],
  ["82084","Acébal","82084010","Localidad simple",-33.2436505576999,-60.837195481459],
  ["82084","Albarellos","82084020","Localidad simple",-33.2413031665306,-60.6365751407418],
  ["82084","Álvarez","82084030","Localidad simple",-33.1306253585247,-60.8039626859934],
  ["82084","Alvear","82084040","Localidad simple",-33.0614584695641,-60.6159765613734],
  ["82084","Arbilla","82084050","Localidad simple",-33.0919516648506,-60.6993159324653],
  ["82084","Arminda","82084060","Localidad simple",-33.2658615254501,-60.9669188397385],
  ["82084","Arroyo Seco","82084070","Localidad simple",-33.1560225761175,-60.5101308080247],
  ["82084","Carmen del Sauce","82084080","Localidad simple",-33.2376879120566,-60.8118679160701],
  ["82084","Coronel Bogado","82084090","Localidad simple",-33.3175115859048,-60.6036347878573],
  ["82084","Coronel Rodolfo S. Domínguez","82084100","Localidad simple",-33.1854760061024,-60.7228633313771],
  ["82084","Cuatro Esquinas","82084110","Localidad simple",-33.2466228889596,-60.7649740219949],
  ["82084","El Caramelo","82084120","Componente de localidad compuesta",-33.1288733975401,-60.7130394393533],
  ["82084","Fighiera","82084130","Localidad simple",-33.1950187794417,-60.4706038463519],
  ["82084","Funes","82084140","Componente de localidad compuesta",-32.922782783063,-60.8121802825957],
  ["82084","General Lagos","82084150","Localidad simple",-33.1121588884353,-60.5665737837063],
  ["82084","Granadero Baigorria","82084160","Componente de localidad compuesta",-32.8613641656775,-60.7062159770826],
  ["82084","Ibarlucea","82084170","Localidad simple",-32.8512561304404,-60.7884936646076],
  ["82084","Kilómetro 101","82084180","Localidad simple",-33.060584803082,-60.6856440118334],
  ["82084","Los Muchachos - La Alborada","82084190","Localidad simple",-33.0915734104105,-60.7354254261055],
  ["82084","Monte Flores","82084200","Localidad simple",-33.0800073993365,-60.6355226681115],
  ["82084","Pérez","82084210","Componente de localidad compuesta",-32.99881116903,-60.7721592101064],
  ["82084","Piñero","82084220","Localidad simple",-33.1112071010783,-60.796496163063],
  ["82084","Pueblo Esther","82084230","Localidad simple",-33.0730969403696,-60.5789195429282],
  ["82084","Pueblo Muñóz","82084240","Localidad simple",-33.1744833504332,-60.8971398400989],
  ["82084","Pueblo Uranga","82084250","Localidad simple",-33.2645299958204,-60.7083345859989],
  ["82084","Puerto Arroyo Seco","82084260","Localidad simple",-33.1315113496399,-60.5078884705177],
  ["82084","Rosario","82084270","Componente de localidad compuesta",-32.9538142575213,-60.6515379354516],
  ["82084","Soldini","82084280","Componente de localidad compuesta",-33.0239868445344,-60.7561883192345],
  ["82084","Villa Amelia","82084290","Localidad simple",-33.1771929125315,-60.6677297311463],
  ["82084","Villa del Plata","82084300","Componente de localidad compuesta",-33.1271769621356,-60.7090282248961],
  ["82084","Villa Gobernador Gálvez","82084310","Componente de localidad compuesta",-33.0224078611601,-60.6336422555152],
  ["82084","Zavalla","82084320","Localidad simple",-33.0215698285974,-60.879303488531],
  ["82091","Aguará Grande","82091010","Localidad simple",-30.1093090599224,-60.9437539322397],
  ["82091","Ambrosetti","82091020","Localidad simple",-30.016999568893,-61.5765785011442],
  ["82091","Arrufo","82091030","Localidad simple",-30.2341495301455,-61.7285807001253],
  ["82091","Balneario La Verde","82091040","Localidad simple",-29.9827373481556,-61.2428659094376],
  ["82091","Capivara","82091050","Localidad simple",-30.4615028173869,-61.2722735128607],
  ["82091","Ceres","82091060","Localidad simple",-29.8823371283479,-61.9452374270961],
  ["82091","Colonia Ana","82091070","Localidad simple",-30.1449998391803,-61.9147917462343],
  ["82091","Colonia Bossi","82091080","Localidad simple",-30.6691245233432,-61.7896030300364],
  ["82091","Colonia Rosa","82091090","Localidad simple",-30.3022785889636,-61.9844913702309],
  ["82091","Constanza","82091100","Localidad simple",-30.664633909429,-61.3207552160732],
  ["82091","Curupaytí","82091110","Localidad simple",-30.397911889967,-61.6518044215672],
  ["82091","Hersilia","82091120","Localidad simple",-30.0056765366847,-61.8396467676821],
  ["82091","Huanqueros","82091130","Localidad simple",-30.0136747533996,-61.2192947646911],
  ["82091","La Cabral","82091140","Localidad simple",-30.0876438007142,-61.1797070550573],
  ["82091","La Lucila","82091145","Localidad simple",-30.4196635334388,-61.0033073134897],
  ["82091","La Rubia","82091150","Localidad simple",-30.1113966728017,-61.7927608545145],
  ["82091","Las Avispas","82091160","Localidad simple",-29.8953127955717,-61.2911992453769],
  ["82091","Las Palmeras","82091170","Localidad simple",-30.6326345828984,-61.6277233886562],
  ["82091","Moisés Ville","82091180","Localidad simple",-30.7182008702613,-61.469140085345],
  ["82091","Monigotes","82091190","Localidad simple",-30.4901359922347,-61.6348224695165],
  ["82091","Ñanducita","82091200","Localidad simple",-30.37245992257,-61.1326015812096],
  ["82091","Palacios","82091210","Localidad simple",-30.7106694051354,-61.6236952048733],
  ["82091","San Cristóbal","82091220","Localidad simple",-30.311687011314,-61.2386444593771],
  ["82091","San Guillermo","82091230","Localidad simple",-30.3602098529676,-61.9178272634037],
  ["82091","Santurce","82091240","Localidad simple",-30.1866452738191,-61.178528021881],
  ["82091","Soledad","82091250","Localidad simple",-30.6225538384456,-60.9166112630514],
  ["82091","Suardi","82091260","Localidad simple",-30.5361453460922,-61.9616805839764],
  ["82091","Villa Saralegui","82091270","Localidad simple",-30.5427027882285,-60.7477102618235],
  ["82091","Villa Trinidad","82091280","Localidad simple",-30.2176460355738,-61.877568026694],
  ["82098","Alejandra","82098010","Localidad simple",-29.9103566747475,-59.8281612200692],
  ["82098","Cacique Ariacaiquín","82098020","Localidad simple",-30.6581364074941,-60.2307356488106],
  ["82098","Colonia Durán","82098030","Localidad simple",-29.5607537201086,-59.927069353713],
  ["82098","La Brava","82098040","Localidad simple",-30.4477825105448,-60.1409356882605],
  ["82098","Romang","82098050","Localidad simple",-29.5018294527814,-59.7485934535059],
  ["82098","San Javier","82098060","Localidad simple",-30.5822068409869,-59.9313985183809],
  ["82105","Arocena","82105010","Localidad simple",-32.0800271942926,-60.9770049639573],
  ["82105","Balneario Monje","82105020","Localidad simple",-32.3349560866515,-60.8760522539552],
  ["82105","Barrancas","82105030","Localidad simple",-32.2366357816462,-60.9827401330363],
  ["82105","Barrio Caima","82105040","Localidad simple",-31.8320800807618,-60.8719647067245],
  ["82105","Barrio El Pacaá - Barrio Comipini","82105050","Localidad simple",-32.1313356998216,-60.9282685049176],
  ["82105","Bernardo de Irigoyen","82105060","Localidad simple",-32.1709306189148,-61.1572748282837],
  ["82105","Casalegno","82105070","Localidad simple",-32.2638306241466,-61.1261488657874],
  ["82105","Centeno","82105080","Localidad simple",-32.298023717348,-61.4107241466286],
  ["82105","Coronda","82105090","Localidad simple",-31.975646712145,-60.9201341188126],
  ["82105","Desvío Arijón","82105100","Localidad simple",-31.8727393656094,-60.8896993521491],
  ["82105","Díaz","82105110","Localidad simple",-32.3750588242506,-61.091442512126],
  ["82105","Gaboto","82105120","Localidad simple",-32.4343760818819,-60.8185390941723],
  ["82105","Gálvez","82105130","Localidad simple",-32.0326455920318,-61.2199610274247],
  ["82105","Gessler","82105140","Localidad simple",-31.8770449531764,-61.1288367653983],
  ["82105","Irigoyen","82105150","Localidad simple",-32.16077341012,-61.1104258428642],
  ["82105","Larrechea","82105160","Localidad simple",-31.9361305275575,-61.0477166860407],
  ["82105","Loma Alta","82105170","Localidad simple",-31.9614431890621,-61.1783800456556],
  ["82105","López","82105180","Localidad simple",-31.9069668930749,-61.2799295377437],
  ["82105","Maciel","82105190","Localidad simple",-32.4587652553057,-60.8931126475643],
  ["82105","Monje","82105200","Localidad simple",-32.358735658961,-60.9429043010116],
  ["82105","Puerto Aragón","82105210","Localidad simple",-32.2447218281238,-60.9239839784214],
  ["82105","San Eugenio","82105220","Localidad simple",-32.0768953861827,-61.1174234926527],
  ["82105","San Fabián","82105230","Localidad simple",-32.1383718722873,-60.9832660246346],
  ["82105","San Genaro","82105240","Componente de localidad compuesta",-32.3735383941398,-61.3606569211002],
  ["82105","San Genaro Norte","82105250","Componente de localidad compuesta",-32.3658073636946,-61.3401798286706],
  ["82112","Angeloni","82112010","Localidad simple",-30.8575177090903,-60.6486098681791],
  ["82112","Cayastacito","82112020","Localidad simple",-31.1150071573313,-60.5814003944463],
  ["82112","Colonia Dolores","82112030","Localidad simple",-30.3836825866932,-60.3307254883153],
  ["82112","Esther","82112040","Localidad simple",-31.0434861128335,-60.6448661369776],
  ["82112","Gobernador Crespo","82112050","Localidad simple",-30.3648346894928,-60.4011684048308],
  ["82112","La Criolla","82112060","Localidad simple",-30.2261579523496,-60.3664968225823],
  ["82112","La Penca y Caraguatá","82112070","Localidad simple",-30.3484964424709,-60.5217853393141],
  ["82112","Marcelino Escalada","82112080","Localidad simple",-30.5819493055118,-60.4693860436357],
  ["82112","Naré","82112090","Localidad simple",-30.951076187335,-60.4682102211441],
  ["82112","Pedro Gómez Cello","82112100","Localidad simple",-30.0384743425904,-60.3152431288441],
  ["82112","Ramayón","82112110","Localidad simple",-30.6758153384973,-60.4995553794067],
  ["82112","San Bernardo","82112120","Localidad simple",-30.8905395009228,-60.5751464890852],
  ["82112","San Justo","82112130","Localidad simple",-30.7908665162845,-60.5940368250334],
  ["82112","San Martín Norte","82112140","Localidad simple",-30.3493004076432,-60.3040548934806],
  ["82112","Silva","82112150","Localidad simple",-30.4486399849806,-60.430070013139],
  ["82112","Vera y Pintado","82112160","Localidad simple",-30.1436425790617,-60.3373530550458],
  ["82112","Videla","82112170","Localidad simple",-30.9465032627862,-60.6564412400796],
  ["82119","Aldao","82119010","Localidad simple",-32.7069853236032,-60.8179518202361],
  ["82119","Capitán Bermúdez","82119020","Componente de localidad compuesta",-32.8282349449349,-60.7168207550494],
  ["82119","Carcarañá","82119030","Localidad simple",-32.8588281760163,-61.1523502197424],
  ["82119","Coronel Arnold","82119040","Localidad simple",-33.1066175391399,-60.9665015588484],
  ["82119","Fray Luis Beltrán","82119050","Componente de localidad compuesta",-32.7855581880336,-60.7291236444004],
  ["82119","Fuentes","82119060","Localidad simple",-33.1744416497872,-61.0750536976089],
  ["82119","Luis Palacios","82119070","Localidad simple",-32.784870422621,-60.9076379614075],
  ["82119","Puerto General San Martín","82119080","Componente de localidad compuesta",-32.7190025958741,-60.7334925388318],
  ["82119","Pujato","82119090","Localidad simple",-33.0195733543103,-61.0438316490822],
  ["82119","Ricardone","82119100","Localidad simple",-32.7736805491372,-60.786927658223],
  ["82119","Roldán","82119110","Componente de localidad compuesta",-32.9023879302415,-60.9108827950649],
  ["82119","San Jerónimo Sud","82119120","Localidad simple",-32.8787353332163,-61.0243903952404],
  ["82119","San Lorenzo","82119130","Componente de localidad compuesta",-32.7523069549362,-60.7356209815072],
  ["82119","Timbúes","82119140","Localidad simple",-32.6696252682834,-60.7943548240758],
  ["82119","Villa Elvira","82119150","Componente de localidad compuesta",-32.6429185717722,-60.81770951188],
  ["82119","Villa Mugueta","82119160","Localidad simple",-33.3139349307156,-61.0570695285482],
  ["82126","Cañada Rosquín","82126010","Localidad simple",-32.0562934036888,-61.6025429947826],
  ["82126","Carlos Pellegrini","82126020","Localidad simple",-32.0526642372536,-61.78894991246],
  ["82126","Casas","82126030","Localidad simple",-32.1279976039457,-61.5421282200809],
  ["82126","Castelar","82126040","Localidad simple",-31.6691692674795,-62.0899867120516],
  ["82126","Colonia Belgrano","82126050","Localidad simple",-31.9118940838345,-61.4023835358504],
  ["82126","Crispi","82126060","Localidad simple",-31.7417252131656,-62.0378765362955],
  ["82126","El Trébol","82126070","Localidad simple",-32.2030242455008,-61.7028944914559],
  ["82126","Landeta","82126080","Localidad simple",-32.0138147005941,-62.0611771301988],
  ["82126","Las Bandurrias","82126090","Localidad simple",-32.1991899646564,-61.4927940449511],
  ["82126","Las Petacas","82126100","Localidad simple",-31.8247278111096,-62.1089907898346],
  ["82126","Los Cardos","82126110","Localidad simple",-32.3243031135987,-61.6321111218833],
  ["82126","María Susana","82126120","Localidad simple",-32.2654856687264,-61.9010253248989],
  ["82126","Piamonte","82126130","Localidad simple",-32.1458665241358,-61.9811202181808],
  ["82126","San Jorge","82126140","Localidad simple",-31.898003817155,-61.8603287777206],
  ["82126","San Martín de las Escobas","82126150","Localidad simple",-31.8596737471682,-61.5702157763693],
  ["82126","Sastre","82126160","Localidad simple",-31.7695325241636,-61.8294529565696],
  ["82126","Traill","82126170","Localidad simple",-31.9225991219581,-61.7024471962412],
  ["82126","Wildermuth","82126180","Localidad simple",-31.9469900287545,-61.4025551450022],
  ["82133","Calchaquí","82133010","Localidad simple",-29.8905436040639,-60.285737676357],
  ["82133","Cañada Ombú","82133020","Localidad simple",-28.31083042196,-59.9837166450891],
  ["82133","Colmena","82133030","Localidad simple",-28.7658190432744,-60.0880421430925],
  ["82133","Fortín Olmos","82133040","Localidad simple",-29.0560211845387,-60.4143945851651],
  ["82133","Garabato","82133050","Localidad simple",-28.9553447407242,-60.1384384332404],
  ["82133","Golondrina","82133060","Localidad simple",-28.5588709585467,-60.0251919319472],
  ["82133","Intiyaco","82133070","Localidad simple",-28.6779253668564,-60.0724684333926],
  ["82133","Kilómetro 115","82133080","Localidad simple",-28.8247510907656,-60.2256036446499],
  ["82133","La Gallareta","82133090","Localidad simple",-29.5854889982809,-60.3799393729758],
  ["82133","Los Amores","82133100","Localidad simple",-28.1063721680455,-59.9786648326772],
  ["82133","Margarita","82133110","Localidad simple",-29.6910879587641,-60.2524652684442],
  ["82133","Paraje 29","82133120","Localidad simple",-29.1097652045099,-60.2391297738451],
  ["82133","Pozo de los Indios","82133130","Localidad simple",-28.9451306017322,-60.2520035726174],
  ["82133","Pueblo Santa Lucía","82133140","Localidad simple",-29.2838158063585,-60.4038564051536],
  ["82133","Tartagal","82133150","Localidad simple",-28.6722104503175,-59.8468195282736],
  ["82133","Toba","82133160","Localidad simple",-29.2675884279209,-60.1726559005792],
  ["82133","Vera","82133170","Localidad simple",-29.4629204507651,-60.2133477841634],
  ["86007","Argentina","86007010","Localidad simple",-29.5347584629763,-62.2668040651927],
  ["86007","Casares","86007020","Localidad simple",-28.9529394000082,-62.8005346895448],
  ["86007","Malbrán","86007030","Localidad simple",-29.3480281688774,-62.4374715654784],
  ["86007","Villa General Mitre","86007040","Localidad simple",-29.1446444838565,-62.6541996550291],
  ["86014","Campo Gallo","86014010","Localidad simple",-26.581588722034,-62.8521376221858],
  ["86014","Coronel Manuel L. Rico","86014020","Localidad simple",-26.3836121510521,-61.8096460345963],
  ["86014","Donadeu","86014030","Localidad simple",-26.7266820556935,-62.7208021510899],
  ["86014","Sachayoj","86014040","Localidad simple",-26.671433914307,-61.8174308800717],
  ["86014","Santos Lugares","86014050","Localidad simple",-26.6920901207094,-63.5584892838705],
  ["86021","Estación Atamisqui","86021010","Localidad simple",-28.4946171651834,-63.9414267036415],
  ["86021","Medellín","86021020","Localidad simple",-28.6499385815911,-63.787545374207],
  ["86021","Villa Atamisqui","86021030","Localidad simple",-28.4939256027398,-63.8205160146802],
  ["86028","Colonia Dora","86028010","Localidad simple",-28.603116660495,-62.951072903573],
  ["86028","Herrera","86028020","Localidad simple",-28.4852360558267,-63.0697575257716],
  ["86028","Icaño","86028030","Localidad simple",-28.6784711687351,-62.8846263455873],
  ["86028","Lugones","86028040","Localidad simple",-28.3346445647531,-63.3436023986024],
  ["86028","Real Sayana","86028050","Localidad simple",-28.8166325823721,-62.8455339441355],
  ["86028","Villa Mailín","86028060","Localidad simple",-28.4831042788772,-63.2790903120191],
  ["86035","Abra Grande","86035010","Localidad simple",-27.2931336131427,-64.3790656722545],
  ["86035","Antajé","86035020","Localidad simple",-27.6273165422381,-64.252782204773],
  ["86035","Ardiles","86035030","Localidad simple",-27.415006517686,-64.5005841049021],
  ["86035","Cañada Escobar","86035040","Localidad simple",-27.7093508468277,-64.0345634947704],
  ["86035","Chaupi Pozo","86035050","Localidad simple",-27.5090071798518,-64.4230093979117],
  ["86035","Clodomira","86035060","Localidad simple",-27.5762755617113,-64.1322398015217],
  ["86035","Huyamampa","86035070","Localidad simple",-27.3875685641419,-64.296255139046],
  ["86035","La Aurora","86035080","Localidad simple",-27.4964060720214,-64.2315605665017],
  ["86035","La Banda","86035090","Componente de localidad compuesta",-27.7339063576954,-64.2389609885924],
  ["86035","La Dársena","86035100","Localidad simple",-27.6984439320511,-64.2891593020827],
  ["86035","Los Quiroga","86035110","Localidad simple",-27.6541808200018,-64.3550857252435],
  ["86035","Los Soria","86035120","Localidad simple",-27.6278438576024,-64.3665478243818],
  ["86035","Simbolar","86035130","Localidad simple",-27.6504840077902,-64.1912416790424],
  ["86035","Tramo 16","86035140","Localidad simple",-27.6966791825106,-64.171980690304],
  ["86035","Tramo 20","86035150","Localidad simple",-27.724169959056,-64.119953835997],
  ["86042","Bandera","86042010","Localidad simple",-28.8825052182773,-62.2661992861707],
  ["86042","Cuatro Bocas","86042020","Localidad simple",-28.8813440964016,-61.8646065822],
  ["86042","Fortín Inca","86042030","Localidad simple",-29.1249938081928,-61.9377330722992],
  ["86042","Guardia Escolta","86042040","Localidad simple",-28.9901980198517,-62.1274458413758],
  ["86049","El Deán","86049010","Localidad simple",-27.7173434793387,-64.3318930408752],
  ["86049","El Mojón","86049020","Localidad simple",-27.9899319139286,-64.213355171484],
  ["86049","El Zanjón","86049030","Componente de localidad compuesta",-27.8750408217321,-64.2433909658935],
  ["86049","Los Cardozos","86049040","Localidad simple",-27.9125126696643,-64.1953803450085],
  ["86049","Maco","86049050","Localidad simple",-27.8684490761323,-64.2176846841573],
  ["86049","Maquito","86049060","Localidad simple",-27.883071657444,-64.210364508634],
  ["86049","Morales","86049070","Localidad simple",-27.681136956593,-64.3628119718648],
  ["86049","Puesto de San Antonio","86049080","Localidad simple",-27.6663887276734,-64.3770291350394],
  ["86049","San Pedro","86049090","Localidad simple",-27.9463558793645,-64.1638901235678],
  ["86049","Santa María","86049100","Localidad simple",-27.9515163858504,-64.2196924435025],
  ["86049","Santiago del Estero","86049110","Componente de localidad compuesta",-27.7906472093484,-64.2622741290181],
  ["86049","Vuelta de la Barranca","86049120","Localidad simple",-27.8762024322533,-64.1878789215783],
  ["86049","Yanda","86049130","Localidad simple",-27.9106239556579,-64.2300554961572],
  ["86056","El Caburé","86056010","Localidad simple",-26.0165513217409,-62.3330208736258],
  ["86056","La Firmeza","86056020","Localidad simple",-25.9734494403489,-63.1213348208669],
  ["86056","Los Pirpintos","86056030","Localidad simple",-26.1336342552401,-62.0623998821941],
  ["86056","Los Tigres","86056040","Localidad simple",-25.9094984239476,-62.5920547989978],
  ["86056","Monte Quemado","86056050","Localidad simple",-25.8055238661729,-62.8421851386474],
  ["86056","Nueva Esperanza","86056060","Localidad simple",-26.033847347527,-63.3180059411213],
  ["86056","Pampa de los Guanacos","86056070","Localidad simple",-26.2344065294949,-61.8376679266549],
  ["86056","San José del Boquerón","86056080","Localidad simple",-26.1203999513037,-63.7053351206531],
  ["86056","Urutaú","86056090","Localidad simple",-25.7123774702614,-63.0412762978269],
  ["86063","Ancaján","86063010","Localidad simple",-28.4309064612063,-64.9233001766412],
  ["86063","Choya","86063020","Localidad simple",-28.4942404547901,-64.8563028233751],
  ["86063","Estación La Punta","86063030","Localidad simple",-28.4119636214997,-64.7564290050951],
  ["86063","Frías","86063040","Localidad simple",-28.6399178570768,-65.130637009131],
  ["86063","Laprida","86063050","Localidad simple",-28.3756319929951,-64.5305517169124],
  ["86063","San Pedro","86063070","Localidad simple",-28.4601109681789,-64.8665614531529],
  ["86063","Tapso","86063080","Localidad simple",-28.4037795215625,-65.0964321177706],
  ["86063","Villa La Punta","86063090","Localidad simple",-28.371365281259,-64.7921192520059],
  ["86070","Bandera Bajada","86070010","Localidad simple",-27.2724258053036,-63.5140111288855],
  ["86070","Caspi Corral","86070020","Localidad simple",-27.3907597837259,-63.5489564711117],
  ["86070","Colonia San Juan","86070030","Localidad simple",-27.617543825893,-63.301877607639],
  ["86070","El Crucero","86070040","Localidad simple",-27.5779248328345,-63.3309305482062],
  ["86070","Kilómetro 30","86070050","Localidad simple",-27.3845037887346,-63.5296772428548],
  ["86070","La Cañada","86070060","Localidad simple",-27.7113503879057,-63.776465678451],
  ["86070","La Invernada","86070070","Localidad simple",-27.3853384819687,-63.4863113485715],
  ["86070","Minerva","86070080","Localidad simple",-27.5383379504139,-63.3844467629454],
  ["86070","Vaca Huañuna","86070090","Localidad simple",-27.4744910479525,-63.4699371865895],
  ["86070","Villa Figueroa","86070100","Localidad simple",-27.7220223636284,-63.5077024611833],
  ["86077","Añatuya","86077010","Localidad simple",-28.4645613476513,-62.8371553125604],
  ["86077","Averías","86077020","Localidad simple",-28.7471563597272,-62.4500332099208],
  ["86077","Estación Tacañitas","86077030","Localidad simple",-28.625400373791,-62.6050049232664],
  ["86077","La Nena","86077040","Localidad simple",-28.4600119281847,-61.8401411379321],
  ["86077","Los Juríes","86077050","Localidad simple",-28.4678989822603,-62.1097288458217],
  ["86077","Tomás Young","86077060","Localidad simple",-28.6023457181773,-62.1835145984131],
  ["86084","Lavalle","86084010","Componente de localidad compuesta",-28.1989652184743,-65.1121667400925],
  ["86084","San Pedro","86084020","Componente de localidad compuesta",-27.9573058480013,-65.1704506415815],
  ["86091","El Arenal","86091005","Localidad simple",-26.7716728234233,-64.6015462356661],
  ["86091","El Bobadal","86091010","Localidad simple",-26.7184011548025,-64.3982906362897],
  ["86091","El Charco","86091020","Localidad simple",-27.2257680209403,-64.7003027141644],
  ["86091","El Rincón","86091030","Localidad simple",-26.7333694233426,-64.4768351977429],
  ["86091","Gramilla","86091040","Localidad simple",-27.2971935237082,-64.61075364749],
  ["86091","Isca Yacu","86091050","Localidad simple",-27.0297706094061,-64.6107284533431],
  ["86091","Isca Yacu Semaul","86091060","Localidad simple",-27.033281523993,-64.6122143434088],
  ["86091","Pozo Hondo","86091070","Localidad simple",-27.164621631919,-64.483386426973],
  ["86091","San Pedro","86091080","Localidad simple",-26.7405309182605,-64.3965511764775],
  ["86098","El Colorado","86098010","Localidad simple",-27.916852444404,-62.1779644703931],
  ["86098","El Cuadrado","86098020","Localidad simple",-28.2978508912148,-61.8013595132333],
  ["86098","Matará","86098030","Localidad simple",-28.110413912625,-63.1950712509572],
  ["86098","Suncho Corral","86098040","Localidad simple",-27.9373441459042,-63.4286561024091],
  ["86098","Vilelas","86098050","Localidad simple",-27.9593446946828,-62.6095801174635],
  ["86098","Yuchán","86098060","Localidad simple",-27.7812827220804,-62.9762834233876],
  ["86105","Villa San Martín (Est. Loreto)","86105010","Localidad simple",-28.3039639606794,-64.1851457926154],
  ["86112","Villa Unión","86112010","Localidad simple",-29.4169970813328,-62.7903866994546],
  ["86119","Aerolito","86119010","Localidad simple",-27.2367908165246,-62.3796548631942],
  ["86119","Alhuampa","86119020","Localidad simple",-27.1327719671086,-62.5491667779808],
  ["86119","Hasse","86119030","Localidad simple",-27.0720923042891,-62.6462009108307],
  ["86119","Hernán Mejía Miraval","86119040","Localidad simple",-27.1785919494814,-62.4685537207534],
  ["86119","Las Tinajas","86119050","Localidad simple",-27.4618186135826,-62.9188082355465],
  ["86119","Libertad","86119060","Localidad simple",-27.0762151680819,-63.0708907011301],
  ["86119","Lilo Viejo","86119070","Localidad simple",-26.9408021196944,-62.9565689431121],
  ["86119","Patay","86119080","Localidad simple",-26.843267415023,-62.9328920767785],
  ["86119","Pueblo Pablo Torelo","86119090","Localidad simple",-27.3309034121122,-62.2263991173581],
  ["86119","Quimili","86119100","Localidad simple",-27.6502221618861,-62.4162413545379],
  ["86119","Roversi","86119110","Localidad simple",-27.593467554452,-61.9454404681047],
  ["86119","Tintina","86119120","Localidad simple",-27.0269428383778,-62.7014758111564],
  ["86119","Weisburd","86119130","Localidad simple",-27.3177468248599,-62.5883450951591],
  ["86126","El 49","86126010","Localidad simple",-29.0559761149567,-63.9559623784872],
  ["86126","Sol de Julio","86126020","Localidad simple",-29.562340331816,-63.4575916015313],
  ["86126","Villa Ojo de Agua","86126030","Localidad simple",-29.5029027910505,-63.6939738398896],
  ["86133","El Mojón","86133010","Localidad simple",-26.094177918867,-64.3077511775357],
  ["86133","Las Delicias","86133020","Localidad simple",-26.6821239251425,-64.0011052202083],
  ["86133","Nueva Esperanza","86133030","Localidad simple",-26.2029493632974,-64.2386862818792],
  ["86133","Pozo Betbeder","86133040","Localidad simple",-26.4117975451662,-64.3406016723268],
  ["86133","Rapelli","86133050","Localidad simple",-26.3973763982116,-64.5044626210659],
  ["86133","Santo Domingo","86133060","Localidad simple",-26.2295353888576,-63.7775041035997],
  ["86140","Ramírez de Velazco","86140010","Localidad simple",-29.2346591274202,-63.4745902285706],
  ["86140","Sumampa","86140020","Localidad simple",-29.3856768376799,-63.4739812028011],
  ["86140","Sumampa Viejo","86140030","Localidad simple",-29.3873857117046,-63.4413442606189],
  ["86147","Chañar Pozo de Abajo","86147010","Localidad simple",-27.566815560625,-64.6802356354788],
  ["86147","Chauchillas","86147020","Localidad simple",-27.5214742780514,-64.5558862404344],
  ["86147","Colonia Tinco","86147030","Localidad simple",-27.4319202445614,-64.9313037647627],
  ["86147","El Charco","86147040","Localidad simple",-27.2348881521517,-64.697822026062],
  ["86147","Gramilla","86147050","Localidad simple",-27.3020072164497,-64.6130855140247],
  ["86147","La Nueva Donosa","86147060","Localidad simple",-27.4563912240441,-64.9277000920229],
  ["86147","Los Miranda","86147070","Localidad simple",-27.4719466367193,-64.615993605497],
  ["86147","Los Núñez","86147080","Localidad simple",-27.5338396475268,-64.5310863310616],
  ["86147","Mansupa","86147090","Localidad simple",-27.4611344607229,-64.9065546199272],
  ["86147","Pozuelos","86147100","Localidad simple",-27.3041200176407,-64.7530797214091],
  ["86147","Rodeo de Valdez","86147110","Localidad simple",-27.5527256617804,-64.5111174447533],
  ["86147","El Sauzal","86147120","Localidad simple",-27.491671176486,-64.6013992349245],
  ["86147","Termas de Río Hondo","86147130","Localidad simple",-27.5012564484806,-64.8552586634364],
  ["86147","Villa Giménez","86147140","Localidad simple",-27.574990170048,-64.4753061878465],
  ["86147","Villa Río Hondo","86147150","Localidad simple",-27.5983201543603,-64.8739939701803],
  ["86147","Villa Turística del Embalse de Rio Hondo","86147160","Localidad simple",-27.516849315862,-64.9027287200084],
  ["86147","Vinará","86147170","Localidad simple",-27.379706365694,-64.7967473078135],
  ["86154","Colonia Alpina","86154010","Localidad simple",-30.0603796584751,-62.1051312621271],
  ["86154","Palo Negro","86154020","Localidad simple",-29.6773076972314,-62.1374427216007],
  ["86154","Selva","86154030","Localidad simple",-29.7604898000173,-62.0525063759069],
  ["86161","Colonia El Simbolar","86161020","Localidad simple",-27.7226465873966,-63.8598770739209],
  ["86161","Fernández","86161030","Localidad simple",-27.9241249979993,-63.8937760389577],
  ["86161","Ingeniero Forres","86161040","Localidad simple",-27.8774908793598,-63.979135921475],
  ["86161","Vilmer","86161050","Localidad simple",-27.7878023282581,-64.1510014560828],
  ["86168","Chilca Juliana","86168010","Localidad simple",-28.796459373074,-63.5791247989505],
  ["86168","Los Telares","86168020","Localidad simple",-28.9858790620734,-63.4474428106687],
  ["86168","Villa Salavina","86168030","Localidad simple",-28.804933488379,-63.4286953351841],
  ["86175","Brea Pozo","86175010","Localidad simple",-28.2433820721478,-63.9464098988816],
  ["86175","Estación Robles","86175020","Localidad simple",-28.0511950311521,-63.9907281128401],
  ["86175","Estación Taboada","86175030","Localidad simple",-28.0088248181919,-63.745495295948],
  ["86175","Villa Nueva","86175040","Localidad simple",-28.3143322879508,-63.995766608663],
  ["86182","Garza","86182010","Localidad simple",-28.1529581822136,-63.5345160915478],
  ["86189","Árraga","86189010","Localidad simple",-28.0530238668842,-64.2227939749583],
  ["86189","Nueva Francia","86189020","Localidad simple",-28.1833426920499,-64.1968111536257],
  ["86189","Simbol","86189030","Localidad simple",-28.1030540788067,-64.2130484994317],
  ["86189","Sumamao","86189040","Localidad simple",-28.1717134352764,-64.101040971413],
  ["86189","Villa Silípica","86189050","Localidad simple",-28.1105007595588,-64.1476921495566],
  ["90007","Barrio San Jorge","90007010","Localidad simple",-26.6843396000243,-65.0481349066456],
  ["90007","El Chañar","90007020","Localidad simple",-26.7583605607957,-65.0693888917573],
  ["90007","Macomitas","90007060","Localidad simple",-26.7303436942447,-65.0113600491402],
  ["90007","Piedrabuena","90007070","Localidad simple",-26.7398606901892,-64.6493040222716],
  ["90007","7 de Abril","90007080","Localidad simple",-26.2918847472245,-64.5005128631092],
  ["90007","Villa Benjamín Aráoz","90007090","Localidad simple",-26.5561603640592,-64.7983838278956],
  ["90007","Villa Burruyacú","90007100","Localidad simple",-26.5003323203292,-64.7419938212453],
  ["90007","Villa Padre Monti","90007110","Localidad simple",-26.5064025936102,-64.9998985377047],
  ["06070","Santa Coloma","06070030","Localidad simple",-34.062154134736,-59.5585420642846],
  ["06070","Villa Alsina","06070040","Localidad simple",-33.9096038045591,-59.3882017132282],
  ["06077","Arrecifes","06077010","Localidad simple",-34.064591121211,-60.1025564443537],
  ["06077","Todd","06077020","Localidad simple",-34.0328240475348,-60.1562270065745],
  ["06077","Viña","06077030","Localidad simple",-33.9922765156086,-60.2263211205477],
  ["06084","Barker","06084010","Localidad simple",-37.6424111302365,-59.3889380312926],
  ["90014","Alderetes","90014010","Componente de localidad compuesta",-26.8178526944454,-65.1426249208252],
  ["90014","Banda del Río Salí","90014020","Componente de localidad compuesta",-26.8341699595871,-65.1669245241225],
  ["90014","Colombres","90014040","Componente de localidad compuesta",-26.8835749144059,-65.0999411428556],
  ["90014","Colonia Mayo - Barrio La Milagrosa","90014050","Localidad simple",-26.8339561201266,-64.9893799370396],
  ["90014","Delfín Gallo","90014060","Componente de localidad compuesta",-26.8449239959434,-65.092329372598],
  ["90014","El Bracho","90014070","Localidad simple",-26.9921019189366,-65.1812450251062],
  ["90014","La Florida","90014080","Componente de localidad compuesta",-26.8173334288269,-65.0870147950724],
  ["90014","Las Cejas","90014090","Localidad simple",-26.8878173829847,-64.7430772509051],
  ["90014","Los Ralos","90014100","Localidad simple",-26.8876231040581,-65.0019787670693],
  ["90014","Pacará","90014110","Localidad simple",-26.8992133086383,-65.1492861893341],
  ["90014","Ranchillos","90014120","Localidad simple",-26.9547865827356,-65.0483776049689],
  ["90014","San Andrés","90014130","Localidad simple",-26.8884969343068,-65.1963401762121],
  ["90021","Alpachiri","90021010","Localidad simple",-27.3364644479185,-65.7560706396093],
  ["90021","Alto Verde","90021020","Localidad simple",-27.3793992485609,-65.6079258666537],
  ["90021","Arcadia","90021030","Localidad simple",-27.3069484835773,-65.576067487854],
  ["90021","Barrio San Roque","90021040","Componente de localidad compuesta",-27.3293616351221,-65.5823860081286],
  ["90021","Concepción","90021050","Componente de localidad compuesta",-27.3421785890325,-65.598557597657],
  ["90021","Iltico","90021060","Localidad simple",-27.3359615187055,-65.6527259102121],
  ["90021","La Trinidad","90021070","Componente de localidad compuesta",-27.413472537684,-65.5152314804134],
  ["90021","Medina","90021080","Componente de localidad compuesta",-27.418836093134,-65.5333450199588],
  ["90028","Barrio Casa Rosada","90028010","Localidad simple",-27.0430593855029,-65.4291435588925],
  ["90028","Campo de Herrera","90028020","Localidad simple",-27.0256026652764,-65.3464718463273],
  ["90028","Famaillá","90028030","Localidad simple",-27.0545157767945,-65.4018907516219],
  ["90028","Ingenio Fronterita","90028040","Localidad simple",-27.0354707281152,-65.455616412105],
  ["90035","Graneros","90035010","Localidad simple",-27.6485245594157,-65.4389216777288],
  ["90035","Lamadrid","90035020","Localidad simple",-27.6466143101473,-65.2504927223474],
  ["90035","Taco Ralo","90035030","Localidad simple",-27.8350683836867,-65.1946017699559],
  ["90042","Juan Bautista Alberdi","90042010","Localidad simple",-27.5859774039585,-65.620843677012],
  ["90042","Villa Belgrano","90042020","Localidad simple",-27.5271408525417,-65.614612836175],
  ["90070","Santa Lucía","90070060","Localidad simple",-27.0930813575252,-65.5325624964532],
  ["90070","Sargento Moya","90070070","Localidad simple",-27.2278200846423,-65.6598562004025],
  ["90070","Soldado Maldonado","90070080","Localidad simple",-27.1423360079647,-65.5656822015637],
  ["90070","Teniente Berdina","90070090","Localidad simple",-27.050034787094,-65.4875831419552],
  ["90070","Villa Quinteros","90070100","Componente de localidad compuesta",-27.2536712257246,-65.5524720047211],
  ["90077","Aguilares","90077010","Localidad simple",-27.4313812792775,-65.6183416477363],
  ["90077","Los Sarmientos","90077020","Localidad simple",-27.413720870217,-65.6954398913939],
  ["90077","Río Chico","90077030","Localidad simple",-27.4809961150586,-65.6214061319444],
  ["90077","Santa Ana","90077040","Localidad simple",-27.4722321360222,-65.6841675424243],
  ["90077","Villa Clodomiro Hileret","90077050","Localidad simple",-27.4739466117854,-65.6592300213906],
  ["90084","San Miguel de Tucumán","90084010","Componente de localidad compuesta",-26.82900979033,-65.2105441811048],
  ["90091","Atahona","90091010","Localidad simple",-27.4175004497156,-65.2878399932446],
  ["90091","Monteagudo","90091020","Localidad simple",-27.5109095164641,-65.2776930194392],
  ["90091","Nueva Trinidad","90091030","Localidad simple",-27.4845113363814,-65.4912509331708],
  ["90091","Santa Cruz","90091040","Localidad simple",-27.3865618797716,-65.4563894902029],
  ["90091","Simoca","90091050","Localidad simple",-27.2624226707095,-65.3552894738935],
  ["06021","Mechita","06021030","Componente de localidad compuesta",-35.068013673391,-60.4025971632697],
  ["06021","Pla","06021040","Localidad simple",-35.1243819752343,-60.2200612615259],
  ["06021","Villa Grisolía","06021050","Localidad simple",-35.1096178332808,-60.070551324606],
  ["06021","Villa María","06021060","Localidad simple",-34.8881255447686,-60.3469385614882],
  ["06021","Villa Ortiz","06021070","Localidad simple",-34.8435329449862,-60.3048498633641],
  ["06028","Almirante Brown","06028010","Componente de localidad compuesta",-34.8002849372665,-58.3913639562887],
  ["06035","Avellaneda","06035010","Componente de localidad compuesta",-34.6670197685011,-58.3609838160556],
  ["06042","Ayacucho","06042010","Localidad simple",-37.1536695670417,-58.4895476662462],
  ["06042","La Constancia","06042020","Localidad simple",-37.2286256057071,-58.7603890048806],
  ["06042","Solanet","06042030","Localidad simple",-36.8444984439739,-58.5071421689017],
  ["06042","Udaquiola","06042040","Localidad simple",-36.5637513540211,-58.5333344196536],
  ["06049","Ariel","06049010","Localidad simple",-36.5312544192466,-59.9200651844348],
  ["06049","Azul","06049020","Localidad simple",-36.7795144970312,-59.8586331707413],
  ["06049","Cacharí","06049030","Localidad simple",-36.3805626332947,-59.5030645507265],
  ["06049","Chillar","06049040","Localidad simple",-37.3150113247344,-59.9853181679139],
  ["06049","16 de Julio","06049050","Localidad simple",-37.2020524773603,-60.1652139181813],
  ["06056","Bahía Blanca","06056010","Localidad simple",-38.7138052426005,-62.265959896828],
  ["06056","Cabildo","06056020","Localidad simple",-38.4838572081944,-61.8926015349486],
  ["06056","General Daniel Cerri","06056030","Localidad simple",-38.7136524854985,-62.3924221653991],
  ["06063","Balcarce","06063010","Localidad simple",-37.8482779294345,-58.2551665841248],
  ["06063","Los Pinos","06063020","Localidad simple",-37.9412057603,-58.3225920150442],
  ["06007","Carhué","06007010","Localidad simple",-37.1774801030509,-62.7578962604015],
  ["06007","Colonia San Miguel Arcángel","06007020","Localidad simple",-37.4486186469627,-63.117609405389],
  ["06007","Delfín Huergo","06007030","Localidad simple",-37.3173292631958,-63.2331690622102],
  ["06007","Espartillar","06007040","Componente de localidad compuesta",-37.3563345638716,-62.4387637810214],
  ["06007","Esteban Agustín Gascón","06007050","Localidad simple",-37.4544378016288,-63.2565950033782],
  ["06007","La Pala","06007060","Localidad simple",-36.6613400852941,-63.3661281675236],
  ["06007","Maza","06007070","Localidad simple",-36.7999468137731,-63.3385151506224],
  ["06007","Rivera","06007080","Localidad simple",-37.1583546113813,-63.2442194943605],
  ["06007","Villa Margarita","06007100","Localidad simple",-37.4600992847959,-63.2405658599852],
  ["06007","Yutuyaco","06007110","Localidad simple",-36.9884309445004,-63.133808887439],
  ["06014","Adolfo Gonzales Chaves","06014010","Localidad simple",-38.0333995087596,-60.1003341740637],
  ["06014","De La Garma","06014020","Localidad simple",-37.9635021758562,-60.415659383962],
  ["06413","Morse","06413070","Localidad simple",-34.7608898130707,-60.8419122487126],
  ["06588","Morea","06588080","Localidad simple",-35.5563880098445,-60.5605940553161],
  ["06655","Alvarez Jonte","06655010","Localidad simple",-35.3227800092544,-57.4490768504218],
  ["06882","Lima","06882040","Localidad simple",-34.0436335939636,-59.1973339595539],
  ["14168","La Pampa","14168040","Localidad simple",-30.943220474797,-64.2765349210301],
  ["18028","Tabay","18028030","Localidad simple",-28.3062678179647,-58.2862966985736],
  ["18112","Estación Libertad","18112020","Localidad simple",-30.0125285200771,-57.8591295180443],
  ["42154","Chacharramendi","42154020","Localidad simple",-37.3318147762102,-65.650772794634],
  ["62007","Bahía Creek","62007010","Localidad simple",-41.0954235915941,-63.9092240856567],
  ["66049","Cobos","66049020","Localidad simple",-24.7414709076566,-65.0839324652619],
  ["66056","Yacuy","66056250","Localidad simple",-22.3765769868638,-63.7654304903785],
  ["70056","Huaco","70056030","Localidad simple",-30.1570667184839,-68.4809365791381],
  ["86161","Beltrán","86161010","Localidad simple",-27.8315913828113,-64.061379252439],
  ["90007","El Naranjo","90007030","Localidad simple",-26.6571859218044,-65.0483602838482],
  ["90007","Garmendia","90007040","Localidad simple",-26.5736893005766,-64.5576861101137],
  ["90007","La Ramada","90007050","Localidad simple",-26.6881473308745,-64.9464369337093],
  ["90049","La Cocha","90049010","Localidad simple",-27.7730048354523,-65.5864568354594],
  ["90049","San José de La Cocha","90049020","Localidad simple",-27.7315967012344,-65.5827595206013],
  ["90056","Bella Vista","90056010","Localidad simple",-27.0310036528782,-65.3086376425668],
  ["90056","Estación Aráoz","90056020","Localidad simple",-27.0571152473018,-64.9218123993231],
  ["90056","Los Puestos","90056030","Localidad simple",-27.2808998221653,-65.0190299575107],
  ["90056","Manuel García Fernández","90056040","Localidad simple",-26.9557033913379,-65.272073063004],
  ["90056","Pala Pala","90056050","Localidad simple",-27.0563442946496,-65.2181035623283],
  ["90056","Río Colorado","90056060","Localidad simple",-27.1496800217878,-65.3560513582608],
  ["90056","Santa Rosa de Leales","90056070","Localidad simple",-27.1378928767222,-65.2614173877659],
  ["90056","Villa Fiad - Ingenio Leales","90056080","Localidad simple",-27.0677472403134,-65.2354487523003],
  ["90056","Villa de Leales","90056090","Localidad simple",-27.1942605268211,-65.3095561336322],
  ["90063","Barrio San Felipe","90063010","Componente de localidad compuesta",-26.8749835532106,-65.2322262379924],
  ["90063","El Manantial","90063020","Componente de localidad compuesta",-26.8470394385628,-65.2777798501902],
  ["90063","Ingenio San Pablo","90063030","Localidad simple",-26.8739965593381,-65.3103499893471],
  ["90063","La Reducción","90063040","Localidad simple",-26.9601338991113,-65.3514727517897],
  ["90063","Lules","90063050","Localidad simple",-26.9239379177434,-65.3364017910576],
  ["90070","Acheral","90070010","Localidad simple",-27.12072050474,-65.4705647177524],
  ["90070","Capitán Cáceres","90070020","Localidad simple",-27.1895217713073,-65.6039648120293],
  ["90070","Monteros","90070030","Localidad simple",-27.1674766637374,-65.4987774491472],
  ["90070","Pueblo Independencia","90070040","Localidad simple",-27.2207848342687,-65.527417311463],
  ["90070","Río Seco","90070050","Componente de localidad compuesta",-27.2690482043801,-65.5593459528459],
  ["90091","Villa Chicligasta","90091060","Localidad simple",-27.4352233904382,-65.163544429074],
  ["90098","Amaicha del Valle","90098010","Localidad simple",-26.593637661069,-65.9279885664724],
  ["90098","Colalao del Valle","90098020","Localidad simple",-26.3605355069816,-65.9589195037969],
  ["90098","El Mollar","90098030","Localidad simple",-26.9392209221338,-65.7081542446876],
  ["90098","Tafí del Valle","90098040","Localidad simple",-26.8527978993494,-65.7085573791718],
  ["90105","Barrio El Cruce","90105010","Localidad simple",-26.7081441784822,-65.2200815585158],
  ["90105","Barrio Lomas de Tafí","90105020","Localidad simple",-26.7465814588322,-65.2334174034289],
  ["90105","Barrio Mutual San Martín","90105030","Localidad simple",-26.7180167498877,-65.2249109374961],
  ["90105","Barrio Parada 14","90105040","Localidad simple",-26.7527987012624,-65.248427031041],
  ["90105","Barrio U.T.A. II","90105050","Localidad simple",-26.756263713385,-65.2390248245136],
  ["90105","Diagonal Norte - Luz y Fuerza - Los Pocitos - Villa Nueva Italia","90105060","Componente de localidad compuesta",-26.7815251300033,-65.2193041804806],
  ["90105","El Cadillal","90105070","Localidad simple",-26.6325444298094,-65.2057408343078],
  ["90105","Tafí Viejo","90105080","Localidad simple",-26.7312682798666,-65.2558176904322],
  ["90105","Villa Las Flores","90105090","Localidad simple",-26.7695777143465,-65.2336099390109],
  ["90105","Villa Mariano Moreno - El Colmenar","90105100","Componente de localidad compuesta",-26.7759821127859,-65.2019701714422],
  ["90112","Choromoro","90112010","Localidad simple",-26.4107463918543,-65.319972617968],
  ["90112","San Pedro de Colalao","90112020","Localidad simple",-26.2357654346434,-65.4938515563214],
  ["90112","Villa de Trancas","90112030","Localidad simple",-26.2307317035992,-65.285166490246],
  ["90119","Barrio San José III","90119010","Componente de localidad compuesta",-26.7964431224326,-65.2657159116952],
  ["90119","Villa Carmela","90119020","Localidad simple",-26.7677751896138,-65.2708444093707],
  ["90119","Yerba Buena - Marcos Paz","90119030","Componente de localidad compuesta",-26.8155709297986,-65.269158336311],
  ["94015","Laguna Escondida","94015010","Localidad simple",-54.637686082869,-67.766940855265],
  ["94015","Ushuaia","94015020","Localidad simple",-54.8036404601709,-68.3160624772531],
  ["94008","Río Grande","94008010","Localidad simple",-53.7870473449159,-67.7132350718047],
  ["94008","Tolhuin","94008020","Localidad simple",-54.5113867546733,-67.195804463563]
]

localities_list.each do |department_national_id, name, national_id, category, lat, lon|
  department_aux = Department.where(national_id: department_national_id.to_i).first
  Locality.find_or_create_by(department:department_aux, name: name, national_id: national_id, category: category, lat: lat, lon: lon)
end


CODE

#----------------------------------------------------------
###################### VISTAS DEVISE ######################
#----------------------------------------------------------
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

#----------------------------------------------------------
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
################### ARCHIVOS DE IDIOMA ####################
#----------------------------------------------------------

file 'config/locales/es.yml', <<-CODE 
es:
  simple_calendar:
    previous: "<<"
    next: ">>"
    week: Semana  
  activerecord:
    models:
   
      address:
        one: dirección
        other: direcciones
      
      dependence:
        one: dependencia
        other: dependencias
      
      country:
        one: país
        other: países
      
      locality:
        one: localidad
        other: localidades
      
      department:
        one: departamento
        other: departamentos

      nationality:
        one: nacionalidad
        other: nacionalidades
      
      province:
        one: provincia
        other: provincias

      service:
        one: Servicio
        other: Servicios
      
      service_of_dependence:
        one: "servicio de la dependencia"
        other: "servicios de las dependencias"
      
      study:
        one: "estudio"
        other: "estudios"
    
    attributes:    
    
      address:
        street: "calle"
        number: "número"
        city: "localidad"
        other_address_details: "otros detalles"
      
      country:
        code: "código"
        name: "nombre"

      dependence:
        code: "código"
        name: "nombre"
        complexity: "complejidad"
        abbreviation: "abreviación"
      
      law:
        code: "código"
        description: "descripción"

      locality:
        name: "nombre"
        department: "departamento"
        national_id: "id nacional"
        category: "categoría"

      nationality:
        code: "código"
        name: "nombre"
        country: "país"

      province:
        name: "nombre"
        national_id: "id nac."
        complete_name: "nombre completo"
        iso_name: "nombre ISO"
        lat: "latitud"
        lon: "longitud"
        country: país

      service:
        code: "código"
        name: "nombre"
        complexity: "complejidad"
        abbreviation: "abreviación"

      study:
        level: "nivel"
        number: "número"
        description: "descripción"

      service_of_dependence:
        dependence: "dependencia"
        service: "servicio"
        with_guards: "¿tiene guaridas?"
        headship: "jefatura"
        assistance: "asistencial"
        absenteeism: "ausentismo"
        type_of_passive_guard: "tipo de guardia pasiva"
        description: "descripción"
  date:
    abbr_day_names:
    - dom
    - lun
    - mar
    - mié
    - jue
    - vie
    - sáb
    abbr_month_names:
    -
    - ene
    - feb
    - mar
    - abr
    - may
    - jun
    - jul
    - ago
    - sep
    - oct
    - nov
    - dic
    day_names:
    - domingo
    - lunes
    - martes
    - miércoles
    - jueves
    - viernes
    - sábado
    formats:
      default: "%d/%m/%Y"
      long: "%d de %B de %Y"
      short: "%d de %b"
    month_names:
    -
    - enero
    - febrero
    - marzo
    - abril
    - mayo
    - junio
    - julio
    - agosto
    - septiembre
    - octubre
    - noviembre
    - diciembre
    order:
    - :day
    - :month
    - :year
  datetime:
    distance_in_words:
      about_x_hours:
        one: cerca de 1 hora
        other: cerca de %[count} horas
      about_x_months:
        one: cerca de 1 mes
        other: cerca de %[count} meses
      about_x_years:
        one: cerca de 1 año
        other: cerca de %[count} años
      almost_x_years:
        one: casi 1 año
        other: casi %[count} años
      half_a_minute: medio minuto
      less_than_x_minutes:
        one: menos de 1 minuto
        other: menos de %[count} minutos
      less_than_x_seconds:
        one: menos de 1 segundo
        other: menos de %[count} segundos
      over_x_years:
        one: más de 1 año
        other: más de %[count} años
      x_days:
        one: 1 día
        other: "%[count} días"
      x_minutes:
        one: 1 minuto
        other: "%[count} minutos"
      x_months:
        one: 1 mes
        other: "%[count} meses"
      x_years:
        one: 1 año
        other: "%[count} años"
      x_seconds:
        one: 1 segundo
        other: "%[count} segundos"
    prompts:
      day: Día
      hour: Hora
      minute: Minutos
      month: Mes
      second: Segundos
      year: Año
  errors:
    format: "%[message}"
    messages:
      accepted: "%[attribute} debe ser aceptado"
      blank: "%[attribute} no puede estar en blanco"
      present: "%[attribute} debe estar en blanco"
      confirmation: "%[attribute} no coincide"
      empty: "%[attribute} no puede estar vacío"
      equal_to: "%[attribute} debe ser igual a %[count}"
      even: "%[attribute} debe ser par"
      exclusion: "%[attribute} está reservado"
      greater_than: "%[attribute} ebe ser mayor que %[count}"
      greater_than_or_equal_to: "%[attribute} debe ser mayor que o igual a %[count}"
      inclusion: "%[attribute} no está incluido en la lista"
      invalid: "%[attribute} no es válido"
      less_than: "%[attribute} debe ser menor que %[count}"
      less_than_or_equal_to: "%[attribute} debe ser menor que o igual a %[count}"
      model_invalid: "%[attribute} La validación falló: %[errors}"
      not_a_number: "%[attribute} no es un número"
      not_an_integer: "%[attribute} debe ser un entero"
      odd: "%[attribute} debe ser impar"
      required: "%[attribute} es un campo obligatorio"
      taken: "%[attribute} ya está en uso"
      too_long:
        one: "%[attribute} es demasiado largo (1 carácter máximo)"
        other: "%[attribute} es demasiado largo (%[count} caracteres máximo)"
      too_short:
        one: "%[attribute} es demasiado corto (1 carácter mínimo)"
        other: "%[attribute} es demasiado corto (%[count} caracteres mínimo)"
      wrong_length:
        one: "%[attribute} no tiene la longitud correcta (1 carácter exactos)"
        other: "%[attribute} no tiene la longitud correcta (%[count} caracteres exactos)"
        other_than: "%[attribute}  debe ser distinto de %[count}"
    template:
      body: 'Se encontraron problemas con los siguientes campos:'
      header:
        one: No se pudo guardar este/a %[model} porque se encontró 1 error
        other: No se pudo guardar este/a %[model} porque se encontraron %[count} errores
  
  helpers:
    select:
      prompt: Por favor seleccione
    submit:
      address:
        create: Crear Dirección
        submit: Guardar Dirección
        update: Actualizar Dirección
      city:
        create: Crear Localidad
        submit: Guardar Localidad
        update: Actualizar Localidad
      country:
        create: Crear País
        submit: Guardar País
        update: Actualizar País
      dependence:
        create: Crear Dependencia
        submit: Guardar Dependencia
        update: Actualizar Dependencia
      hour_regime:
        create: Crear Régimen horario
        submit: Guardar Régimen horario
        update: Actualizar Régimen horario
      job_function:
        create: Crear Función laboral
        submit: Guardar Función laboral
        update: Actualizar Función laboral
      law:
        create: Crear Ley
        submit: Guardar Ley
        update: Actualizar Ley
      nationality:
        create: Crear Nacionalidad
        submit: Guardar Nacionalidad
        update: Actualizar Nacionalidad
      office:
        create: Crear Oficina
        submit: Guardar Oficina
        update: Actualizar Oficina
      position:
        create: Crear Cargo
        submit: Guardar Cargo
        update: Actualizar Cargo
      profession:
        create: Crear Profesión
        submit: Guardar Profesión
        update: Actualizar Profesión
      payment:
        create: Crear pago
        submit: Guardar pago
        update: Actualizar pago

  number:
    currency:
      format:
        delimiter: "."
        format: "%u %n"
        precision: 2
        separator: ","
        significant: false
        strip_insignificant_zeros: false
        unit: "$"
    format:
      delimiter: "."
      precision: 3
      separator: ","
      significant: false
      strip_insignificant_zeros: false
    human:
      decimal_units:
        format: "%n %u"
        units:
          billion: mil millones
          million:
            one: millón
            other: millones
          quadrillion: mil billones
          thousand: mil
          trillion:
            one: billón
            other: billones
          unit: ''
      format:
        delimiter: ''
        precision: 1
        significant: true
        strip_insignificant_zeros: true
      storage_units:
        format: "%n %u"
        units:
          byte:
            one: Byte
            other: Bytes
          gb: GB
          kb: KB
          mb: MB
          tb: TB
    percentage:
      format:
        delimiter: ''
        format: "%n %"
    precision:
      format:
        delimiter: ''
  support:
    array:
      last_word_connector: " y "
      two_words_connector: " y "
      words_connector: ", "
  time:
    am: am
    formats:
      default: "%A, %d de %B de %Y %H:%M:%S %z"
      long: "%d de %B de %Y %H:%M"
      short: "%d de %b %H:%M"
    pm: pm
CODE
#----------------------------------------------------------
file 'config/locales/devise.es.yml', <<-CODE 
es:
  activerecord:
    attributes:
      user:
        confirmation_sent_at: Confirmación enviada a
        confirmation_token: Código de confirmación
        confirmed_at: Confirmado en
        created_at: Creado en
        current_password: Contraseña actual
        current_sign_in_at: Fecha del ingreso actual
        current_sign_in_ip: IP del ingreso actual
        email: Email
        encrypted_password: Contraseña cifrada
        failed_attempts: Intentos fallidos
        last_sign_in_at: Fecha del último ingreso
        last_sign_in_ip: IP del último inicio
        locked_at: Fecha de bloqueo
        password: Contraseña
        password_confirmation: Confirmación de la contraseña
        remember_created_at: Fecha de 'Recordarme'
        remember_me: Recordarme
        reset_password_sent_at: Fecha de envío de código para contraseña
        reset_password_token: Código para restablecer contraseña
        sign_in_count: Cantidad de ingresos
        unconfirmed_email: Email no confirmado
        unlock_token: Código de desbloqueo
        updated_at: Actualizado en
    models:
      user:
        one: usuario
        other: usuarios
  devise:
    confirmations:
      confirmed: Tu cuenta ha sido confirmada satisfactoriamente.
      new:
        resend_confirmation_instructions: Reenviar instrucciones de confirmación
      send_instructions: Vas a recibir un correo con instrucciones sobre cómo confirmar tu cuenta en unos minutos.
      send_paranoid_instructions: Si tu correo existe en nuestra base de datos, en unos minutos recibirás un correo con instrucciones sobre cómo confirmar tu cuenta.
    failure:
      already_authenticated: Ya has iniciado sesión.
      inactive: Tu cuenta aún no ha sido activada.
      invalid: "%{authentication_keys} o contraseña inválidos."
      last_attempt: Tienes un intento más antes de que tu cuenta sea bloqueada.
      locked: Tu cuenta está bloqueada.
      not_found_in_database: "%{authentication_keys} o contraseña inválidos."
      timeout: Tu sesión expiró. Por favor, inicia sesión nuevamente para continuar.
      unauthenticated: Tienes que iniciar sesión para poder continuar.
      unconfirmed: Tienes que confirmar tu cuenta para poder continuar.
    mailer:
      confirmation_instructions:
        action: Confirmar mi cuenta
        greeting: "¡Bienvenido %{recipient}!"
        instruction: 'Usted puede confirmar el correo electrónico de su cuenta a través de este enlace:'
        subject: Instrucciones de confirmación
      email_changed:
        greeting: "¡Hola %{recipient}! "
        message: Estamos contactando contigo para notificarte que tu email ha sido cambiado a %{email}.
        message_unconfirmed:
        subject: Email cambiado
      password_change:
        greeting: "¡Hola %{recipient}!"
        message: Lo estamos contactando para notificarle que su contraseña ha sido cambiada.
        subject: Contraseña cambiada
      reset_password_instructions:
        action: Cambiar mi contraseña
        greeting: "¡Hola %{recipient}!"
        instruction: Alguien ha solicitado un enlace para cambiar su contraseña, lo que se puede realizar a través del siguiente enlace.
        instruction_2: Si usted no lo ha solicitado, por favor ignore este correo electrónico.
        instruction_3: Su contraseña no será cambiada hasta que usted acceda al enlace y cree una nueva.
        subject: Instrucciones de recuperación de contraseña
      unlock_instructions:
        action: Desbloquear mi cuenta
        greeting: "¡Hola %{recipient}!"
        instruction: 'Haga click en el siguiente enlace para desbloquear su cuenta:'
        message: Su cuenta ha sido bloqueada debido a una cantidad excesiva de intentos infructuosos para ingresar.
        subject: Instrucciones para desbloquear
    omniauth_callbacks:
      failure: No has sido autorizado en la cuenta %{kind} porque "%{reason}".
      success: Has sido autorizado satisfactoriamente en la cuenta %{kind}.
    passwords:
      edit:
        change_my_password: Cambiar mi contraseña
        change_your_password: Cambie su contraseña
        confirm_new_password: Confirme la nueva contraseña
        new_password: Nueva contraseña
      new:
        forgot_your_password: "¿Ha olvidado su contraseña?"
        send_me_reset_password_instructions: Envíeme las instrucciones para resetear mi contraseña
      no_token: No puedes acceder a esta página si no es a través de un enlace para resetear tu contraseña. Si has llegado hasta aquí desde el email para resetear tu contraseña, por favor asegúrate de que la URL introducida está completa.
      send_instructions: Recibirás un correo con instrucciones sobre cómo resetear tu contraseña en unos pocos minutos.
      send_paranoid_instructions: Si tu correo existe en nuestra base de datos, recibirás un correo con instrucciones sobre cómo resetear tu contraseña en tu bandeja de entrada.
      updated: Se ha cambiado tu contraseña. Ya iniciaste sesión.
      updated_not_active: Tu contraseña fue cambiada.
    registrations:
      destroyed: "¡Adiós! Tu cuenta ha sido cancelada correctamente. Esperamos verte pronto."
      edit:
        are_you_sure: "¿Está usted seguro?"
        cancel_my_account: Anular mi cuenta
        currently_waiting_confirmation_for_email: 'Actualmente esperando la confirmacion de: %{email} '
        leave_blank_if_you_don_t_want_to_change_it: dejar en blanco si no desea cambiarla
        title: Editar %{resource}
        unhappy: "¿Disconforme?"
        update: Actualizar
        we_need_your_current_password_to_confirm_your_changes: necesitamos su contraseña actual para confirmar los cambios
      new:
        sign_up: Registrarse
      signed_up: Bienvenido. Tu cuenta fue creada.
      signed_up_but_inactive: Tu cuenta ha sido creada correctamente. Sin embargo, no hemos podido iniciar la sesión porque tu cuenta aún no está activada.
      signed_up_but_locked: Tu cuenta ha sido creada correctamente. Sin embargo, no hemos podido iniciar la sesión porque que tu cuenta está bloqueada.
      signed_up_but_unconfirmed: Se ha enviado un mensaje con un enlace de confirmación a tu correo electrónico. Abre el enlace para activar tu cuenta.
      update_needs_confirmation: Has actualizado tu cuenta correctamente, pero es necesario confirmar tu nuevo correo electrónico. Por favor, comprueba tu correo y sigue el enlace de confirmación para finalizar la comprobación del nuevo correo electrónico.
      updated: Tu cuenta se ha actualizado.
      updated_but_not_signed_in: Su cuenta se ha actualizado correctamente, pero como se cambió su contraseña, debe iniciar sesión nuevamente
    sessions:
      already_signed_out: Sesión finalizada.
      new:
        sign_in: Iniciar sesión
      signed_in: Sesión iniciada.
      signed_out: Sesión finalizada.
    shared:
      links:
        back: Atrás
        didn_t_receive_confirmation_instructions: "¿No ha recibido las instrucciones de confirmación?"
        didn_t_receive_unlock_instructions: "¿No ha recibido instrucciones para desbloquear?"
        forgot_your_password: "¿Ha olvidado su contraseña?"
        sign_in: Iniciar sesión
        sign_in_with_provider: Iniciar sesión con %{provider}
        sign_up: Registrarse
      minimum_password_length:
        one: "(%{count} caractere como mínimo)"
        other: "(%{count} caracteres como mínimo)"
    unlocks:
      new:
        resend_unlock_instructions: Reenviar instrucciones para desbloquear
      send_instructions: Vas a recibir instrucciones para desbloquear tu cuenta en unos pocos minutos.
      send_paranoid_instructions: Si tu cuenta existe, vas a recibir instrucciones para desbloquear tu cuenta en unos pocos minutos.
      unlocked: Tu cuenta ha sido desbloqueada. Ya puedes iniciar sesión.
  errors:
    messages:
      already_confirmed: ya ha sido confirmado, por favor intenta iniciar sesión
      confirmation_period_expired: necesita confirmarse dentro de %{period}, por favor solicita una nueva
      expired: ha expirado, por favor solicita una nueva
      not_found: no se ha encontrado
      not_locked: no estaba bloqueada
      not_saved:
        one: 'Ocurrió un error al tratar de guardar %{resource}:'
        other: 'Ocurrieron %{count} errores al tratar de guardar %{resource}:'

CODE
#----------------------------------------------------------
file 'config/locales/rails_admin.es.yml', <<-CODE 
es:
  admin:
    actions:
      bulk_delete:
        breadcrumb: Eliminación Múltiple
        bulk_link: Eliminar los %{model_label_plural} seleccionados
        menu: Eliminación Múltiple
        title: Eliminar %{model_label_plural}
      dashboard:
        breadcrumb: Panel de control
        menu: Panel de control
        title: Administración del Sitio
      delete:
        breadcrumb: Eliminar
        done: Eliminado
        link: Eliminar  '%{object_label}'
        menu: Eliminar
        title: Eliminar %{model_label} '%{object_label}'
      edit:
        breadcrumb: Editar
        done: Actualizado
        link: Editar este  %{model_label}
        menu: Editar
        title: Editar %{model_label} '%{object_label}'
      export:
        breadcrumb: Exportar
        bulk_link: Exportar Seleccionados %{model_label_plural}
        done: exportado
        link: Exportar   %{model_label_plural}  encontrados
        menu: Exportar
        title: Exportar %{model_label_plural}
      history_index:
        breadcrumb: Historial
        menu: Historial
        title: Historial para %{model_label_plural}
      history_show:
        breadcrumb: Historial
        menu: Historial
        title: Historial para %{model_label} '%{object_label}'
      index:
        breadcrumb: "%{model_label_plural}"
        menu: Lista
        title: Lista de %{model_label_plural}
      new:
        breadcrumb: Nuevo
        done: creado
        link: Añadir un nuevo %{model_label}
        menu: Añadir Nuevo
        title: Nuevo  %{model_label}
      show:
        breadcrumb: "%{object_label}"
        menu: Ver
        title: Detalles para  %{model_label} "%{object_label}"
      show_in_app:
        menu: Ver en la aplicación
    export:
      click_to_reverse_selection: Haga click para invertir la selección
      confirmation: Exportar a %{name}
      csv:
        col_sep: Separador de columnas
        col_sep_help: Deje en blanco para el de defecto ('%{value}')
        default_col_sep: ","
        encoding_to: Codificar a
        encoding_to_help: 'Elija la codificación de salida. Deje en blanco para no cambiar la codificación actual: (%{name})'
        header_for_association_methods: "%{name} [%{association}]"
        header_for_root_methods: "%{name}"
        skip_header: Sin cabecera
        skip_header_help: No incluir un encabezado (sin descripción de los campos)
      display: 'Mostrar %{name}: %{type}'
      empty_value_for_associated_objects: "<vacío>"
      fields_from: Campos de %{name}
      fields_from_associated: Campos del %{name} asociado
      options_for: Opciones para %{name}
      select: Seleccione los campos a exportar
    flash:
      error: "%{name} no se ha %{action}"
      model_not_found: El modelo '%{model}' no se pudo encontrar
      noaction: No se llevó a cabo ninguna acción
      object_not_found: "%{model} con id '%{id}' no se pudo encontrar"
      successful: "%{name} %{action} con éxito"
    form:
      all_of_the_following_related_items_will_be_deleted: "? Los siguientes elementos relacionados pueden ser eliminados o quedar huérfanos:"
      are_you_sure_you_want_to_delete_the_object: "¿Está seguro de que quiere eliminar este %{model_name}"
      basic_info: Información Básica
      bulk_delete: 'Los siguientes objetos serán eliminados, lo cual puede eliminar o dejar huérfanas algunas de sus dependencias relacionadas:'
      cancel: Cancelar
      char_length_of: longitud de
      char_length_up_to: longitud de hasta
      confirmation: Si, estoy seguro
      new_model: "%{name} (nuevo)"
      one_char: carácter
      optional: Opcional
      required: Requerido
      save: Guardar
      save_and_add_another: Guardar y añadir otro
      save_and_edit: Guardar y editar
    misc:
      add_filter: Añadir filtro
      add_new: Agregar nuevo
      ago: atrás
      bulk_menu_title: Elementos seleccionados
      chose_all: Elegir todos
      chosen: Elegido %{name}
      clear_all: Borrar todos
      down: Abajo
      filter: Filtrar
      filter_date_format: dd/mm/yy
      log_out: Desconectar
      navigation: Navegación
      refresh: Actualizar
      remove: Quitar
      search: Buscar
      show_all: Mostrar todo
      up: Arriba
    table_headers:
      changes: Cambios
      created_at: Fecha/Hora
      item: Elemento
      last_used: "Último uso"
      message: Mensaje
      model_name: Nombre del modelo
      records: Registros
      username: Usuario
    home:
      name: Inicio
    pagination:
      next: Siguiente &raquo;
      previous: "&laquo; Anterior"
      truncate: "…"
CODE

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


#----------------------------------------------------------
######################## ASSETS ###########################
#----------------------------------------------------------

inject_into_file 'app/javascript/packs/application.js', :after => 'import "channels"' do
"\nimport '@fortawesome/fontawesome-free/css/all'
global.toastr = require('toastr')

// DATATABLE
require('datatables.net-bs5')

// SELECT2
import 'select2'
import 'select2/dist/css/select2.css'

//BOOTSTRAP
// import 'bootstrap/js/src/alert'  
// import 'bootstrap/js/src/button'  
// import 'bootstrap/js/src/carousel'  
import 'bootstrap/js/src/collapse'  
import 'bootstrap/js/src/dropdown'  
// import 'bootstrap/js/src/modal'  
// import 'bootstrap/js/src/popover'  
import 'bootstrap/js/src/scrollspy'  
// import 'bootstrap/js/src/tab'  
// import 'bootstrap/js/src/toast'  
// import 'bootstrap/js/src/tooltip'

//FLATPICKR
require('flatpickr')
import flatpickr from 'flatpickr';
import { Spanish } from 'flatpickr/dist/l10n/es.js'"
end

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

#----------------------------------------------------------
#remove_file 'app/assets/stylesheets/application.css'
file 'app/javascript/packs/application.scss', <<-CODE 

$blue: #4e719c !default;

@import "~bootstrap/scss/bootstrap";
@import "toastr";
@import "flatpickr/dist/flatpickr.css";

html {
  height:100%;
}

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
  min-height: 60px;;
}

.select2-container--bootstrap .select2-selection--single {
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
  padding: 0.5rem 0.75rem;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.select2-container .select2-selection--single {
  height: 39px !important;
}

.flatpickr[readonly] {
  background-color: white;
  opacity: 1; 
  cursor: pointer;  
}
CODE



#----------------------------------------------------------
###################### AFTER BUNDLE #######################
#----------------------------------------------------------

after_bundle do

  # Reiniciar BD
  rails_command "db:environment:set RAILS_ENV=development"
  rails_command "db:drop"
  rails_command "db:create"

  #----------------------------------------------------------
  #---------- Definir jQuery como variable goblal -----------
  #----------------------------------------------------------
  inject_into_file 'config/webpack/environment.js', :after => "const { environment } = require('@rails/webpacker')" do
  "\n
  const webpack = require('webpack')

  environment.plugins.append('Provide', new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: 'popper.js/dist/popper'
  }))"
  end

  #----------------------------------------------------------
  #---------- Reemplazar el directorio del asset ------------
  #----------------------------------------------------------
  run "mv app/javascript app/frontend"
  run "sed -i 's/javascript/frontend/g' config/webpacker.yml"

  
  #----------------------------------------------------------
  #------------------ INSTALAR LIBRERIAS --------------------
  #----------------------------------------------------------
  
  run "yarn add jquery@3.6.0"
  run "yarn add moment"
  run "yarn add @popperjs/core@2.9.2"
  run "yarn add bootstrap@5.0.0-beta3"
  run "yarn add toastr"
  run "yarn add @fortawesome/fontawesome-free"
  run "yarn add datatables.net-bs5"
  run "yarn add datatables.net-responsive-bs5"
  run "yarn add select2"
  run "yarn add bootstrap-datepicker"
  run "yarn add flatpickr"

  


  #----------------------------------------------------------
  #----------------- USUARIOS Y PERMISOS --------------------
  #----------------------------------------------------------

  # Instalar y configurar gemas de Usuarios y Permisos
  generate("devise:install")
  generate("devise User")
  generate("cancan:ability")
  generate("rolify Role User")

  # Configurar ability de CanCan
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

  # Instalar gema de administración
  generate("rails_admin:install")
  generate("paper_trail:install [--with-changes]")

  # Cambiar configuración de Rails Admin
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

  # Instalar papertrails
  generate("paper_trail:install [--with-changes]")
  
  # Generar Migraciones y Scaffolds
  #generate("migration AddUsernameToUser username:string")

  # Insertando el metodo admin? a la clase User
  inject_into_file 'app/models/user.rb', :before => "end" do
  "
  def admin?
    return has_role? :admin
  end\n"
  end

  #----------------------------------------------------------
  #------------------------- HOME ---------------------------
  #----------------------------------------------------------

  # Setear la ruta de inicio
  route "root to: 'welcome#index'"

  # Obtener el favicon de chubut
  run "wget http://www.chubut.gov.ar/favicon.ico -P app/assets/images"

  #----------------------------------------------------------
  #---------------------- BASE DE DATOS ---------------------
  #----------------------------------------------------------

  # Crea clases iniciales
  generate("scaffold Country code:string name:string")
  generate("scaffold Nationality code:string name:string country:references")  
  generate("scaffold Province iso_id:string name:string national_id:integer  country:references complete_name:string iso_name:string lat:decimal{8,2} lon:decimal{8,2}")
  generate("scaffold Department complete_name:string name:string national_id:integer province:references category:string lat:decimal{8,2} lon:decimal{8,2}")
  generate("scaffold Locality name:string national_id:integer department:references category:string lat:decimal{8,2} lon:decimal{8,2}")
  generate("scaffold events title:string start:datetime end:datetime url:string classNames:string backgroundColor:string borderColor:string textColor:string")

  # Correr las Migraciones
  rails_command "db:migrate"

  # Poblar la Base de Datos con información Inicial
  rails_command "db:seed"

end


