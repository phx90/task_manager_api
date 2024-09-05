POST /signup: Cria um novo usuário.

{
  "name": "xx",
  "email": "xx@email.com",
  "password": "xxx",
  "password_confirmation": "xxx"
}

POST /login: Faz o login e retorna o token JWT.
{
  "email": "xx@email.com",
  "password": "xxx"
}

Usuários (Somente usuários autenticados):
GET /users: Lista todos os usuários (importante: considerar cenários com grande quantidade de dados).
GET /users/:id: Exibe as informações de um usuário específico.
PUT /users/:id: Atualiza as informações de um usuário específico.
DELETE /users/:id: Exclui um usuário.

Projetos (Somente usuários autenticados):
GET /projects: Lista todos os projetos do usuário autenticado (importante: considerar cenários com grande quantidade de dados).
POST /projects: Cria um novo projeto.

{
  "name": "Projeto Teste",
  "description": "Descrição do projeto teste"
}

GET /projects/:id: Exibe um projeto específico.
PUT /projects/:id: Atualiza um projeto específico.
DELETE /projects/:id: Exclui um projeto.

Tarefas (Somente usuários autenticados):
GET /tasks: Lista todas as tarefas dos projetos do usuário autenticado (importante: considerar cenários com grande quantidade de dados).
POST /tasks: Cria uma nova tarefa.

{
  "task": {
    "title": "Minha Nova Tarefa",
    "description": "Descrição da tarefa",
    "completed": false
  },
  "project_id": 1
}

GET /tasks/:id: Exibe uma tarefa específica.
PUT /tasks/:id: Atualiza uma tarefa específica.
DELETE /tasks/:id: Exclui uma tarefa.
