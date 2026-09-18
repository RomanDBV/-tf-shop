# Terraform AWS Workshop

Навчальний проєкт з Terraform, HCP Terraform та AWS.

Основні технології: Terraform, HCP Terraform, AWS IAM/OIDC, EC2, S3, RDS PostgreSQL, Lambda, VPC, SSM Parameter Store.

## Завдання 1 — HCP Terraform

Зареєструватися в HCP Terraform, створити організацію та CLI-driven workspace з тегом `workshop`. Створити початкову конфігурацію Terraform з AWS provider та HCP Terraform 
Cloud backend.

Виконано:
- створено HCP Terraform organization;
- налаштовано workspace;
- додано AWS provider `~> 6.0`;
- виконано `terraform init`;
- `terraform validate` — успішно;
- початковий `terraform plan` — без змін.

## Завдання 2 — AWS OIDC

Створити OIDC provider для HCP Terraform та IAM Web Identity role. Обмежити trust policy організацією та workspace з префіксом `workshop`.

Виконано:
- створено OIDC provider для HCP Terraform;
- створено IAM role;
- налаштовано trust policy;
- додано необхідні AWS permissions для роботи лабораторної.

## Завдання 3 — Dynamic Credentials

Налаштувати AWS authentication HCP Terraform через:

`TFC_AWS_PROVIDER_AUTH=true`

та ARN IAM role.

Додати AWS provider для `eu-central-1`, `aws_caller_identity` та output з AWS Account ID.

Виконано успішно. HCP Terraform отримує AWS credentials через OIDC без статичних AWS access keys.

`aws_caller_identity` успішно повернув AWS Account ID.

## Завдання 4 — Workspaces

Створити окремі Terraform workspaces для dev та prod та перевірити перемикання середовища.

Виконано:
- створено `workshop-dev`;
- створено `workshop-prod`;
- перевірено `terraform workspace list`;
- додано output поточного environment;
- перевірено зміну output при перемиканні workspace.

## Завдання 5 — IAM для EC2 та S3

Дати майбутньому EC2 серверу право читати S3 bucket.

IAM policy сформована через:

`data "aws_iam_policy_document"`

Створено:
- IAM role для EC2;
- S3 read policy;
- policy attachment;
- instance profile.

Конфігурацію перевірено через `terraform fmt`, `terraform validate` та `terraform plan`.

## Завдання 6 — Security Group

Створити Security Group, де ingress rules генеруються зі списку портів.

Використано:

`allowed_ports = [22, 80, 443]`

та `dynamic "ingress"`.

Terraform генерує правила для TCP портів:
- 22;
- 80;
- 443.

Конфігурація успішно пройшла `terraform validate` та `terraform plan`.

## Завдання 7 — EC2 та S3 object

Покласти текстовий файл у S3 та запустити EC2 `t3.micro`.

Створено:
- `hello.txt`;
- `aws_s3_object`;
- EC2 configuration;
- instance profile;
- Security Group;
- SSH key;
- `user_data.sh.tftpl`.

User data винесено в окремий template-файл. Ім'я S3 bucket передається через `templatefile()`.

## Завдання 8 — AWS data sources

Прибрати вручну прописані значення AWS Account ID та region там, де їх можна отримувати автоматично.

Додано:
- `data.aws_caller_identity.current`;
- `data.aws_region.current`.

Terraform успішно отримує поточний AWS account та region через data sources.

## Завдання 9 — S3 module

Створено reusable Terraform module:

`modules/bucket`

Модуль приймає:
- `name_prefix`;
- `versioning_enabled`;
- `reader_arns`;
- `tags`.

Модуль керує:
- S3 bucket;
- versioning;
- bucket policy.

AWS provider усередині модуля окремо не оголошується.

## Завдання 10 — Module outputs та moved

До S3 module додано outputs:
- bucket name;
- bucket ARN;
- policy ID/ARN information.

Для перенесення існуючого S3 resource до module використано Terraform `moved` block.

Це дозволяє змінювати адресу Terraform resource без навмисного перестворення самого ресурсу.

## Завдання 11 — Другий S3 bucket

Повторно використано `modules/bucket` для створення окремого logs bucket.

Для нього:
- інший name prefix;
- versioning вимкнено;
- `reader_arns = []`.

Це демонструє повторне використання одного Terraform module для різних ресурсів.

## Завдання 12 — Variable validation

До variables модуля додано validation.

`name_prefix`:
- тільки lowercase;
- цифри;
- дефіс;
- максимальна довжина 40 символів.

`reader_arns` може бути порожнім.

`versioning_enabled` має default value.

Validation додатково перевірено навмисно неправильним значенням `TF-shop...`. Terraform правильно повернув `Invalid value for variable`.

## Завдання 13 — Amazon RDS PostgreSQL

Створено керовану PostgreSQL database.

Налаштовано:
- PostgreSQL;
- `db.t4g.micro`;
- DB subnet group у декількох Availability Zones;
- окремий Security Group;
- доступ на 5432 тільки від Security Group EC2;
- generated password;
- `publicly_accessible = false`.

Після створення AWS CLI показав стан:

`available`

## Завдання 14 — AWS Lambda

Створено Lambda function, яка читає `hello.txt` із S3 та повертає його вміст.

Lambda source code упаковується Terraform через archive data source.

Також створено:
- Lambda execution role;
- S3 permissions;
- Lambda Function URL.

Перевірка:

`HTTP/1.1 200 OK`

Відповідь:

`Hello from tf-shop S3 bucket`

## Завдання 15 — EC2 → RDS

Перевірено доступ до PostgreSQL.

EC2 → RDS:

підключення через `psql` успішне.

Локальний Mac → RDS:

з'єднання на порт 5432 завершується timeout.

Це підтверджує, що база не доступна безпосередньо з Internet.

Після перевірки RDS instance було видалено через Terraform.

## Завдання 16 — Lambda у VPC

Lambda перенесена у private subnets VPC.

Налаштовано:
- private subnet IDs;
- Lambda Security Group;
- VPC configuration.

Після перенесення функція втратила прямий outbound Internet access.

Причина: private subnets не мають прямого маршруту до Internet Gateway.

У production для outbound Internet access використовують NAT Gateway/NAT instance, а для приватного доступу до підтримуваних AWS services — VPC Endpoints/PrivateLink.

## Завдання 17 — Terraform Import

У AWS Console вручну створено CloudWatch Log Group:

`/tf-shop/import-lab`

Потім ресурс описано в Terraform та імпортовано в state.

Результат:

`Import successful!`

Після import:

`No changes. Your infrastructure matches the configuration.`

Terraform почав керувати ресурсом без його перестворення.

## Завдання 18 — Sensitive values та Terraform State

Згенеровано RSA private key через Terraform TLS provider.

Output позначено:

`sensitive = true`

Команда `terraform output` показує:

`private_key = <sensitive>`

При цьому значення private key все одно присутнє у Terraform state.

Висновок: `sensitive` лише приховує секрет у звичайному CLI output, але не видаляє його зі state. Terraform state потрібно вважати конфіденційним, обмежувати доступ до нього 
та для реальних секретів за можливості використовувати спеціалізовані secret stores.

## Завдання 19 — Replace EC2

Для примусового перестворення тільки EC2 використано:

`terraform apply -replace=aws_instance.web -target=aws_instance.web`

Результат:

`1 added, 0 changed, 1 destroyed`

`-replace` примусово перестворив EC2 instance.

У цій лабораторній `-target` використано для ізоляції операції від решти інфраструктури через наявний drift у state.

## Завдання 20 — AWS Systems Manager Parameter Store

Налаштування `/tf-shop/environment` збережено в AWS Systems Manager Parameter Store.

Terraform читає його через:

`data "aws_ssm_parameter" "environment"`

Parameter Store зручніший, коли значення потрібно централізовано зберігати в AWS та використовувати між різними сервісами або конфігураціями.

Звичайна Terraform variable простіша для локальних і несекретних параметрів. Parameter Store створює додаткову залежність від AWS та потребує IAM permissions.

## Завдання 21 — Drift та lifecycle ignore_changes

В AWS Console до EC2 вручну додано тег:

`ExternalAutomation = enabled`

Terraform спочатку виявив drift та запропонував видалити цей тег:

`ExternalAutomation = enabled -> null`

До EC2 resource додано:

`lifecycle { ignore_changes = [tags["ExternalAutomation"]] }`

Після цього Terraform перестав намагатися видалити саме `ExternalAutomation`, але продовжив контролювати інші tags та attributes.

Таким чином `ignore_changes` застосовано тільки до конкретного поля, а не до всього ресурсу.

## Що було найскладнішим

Найскладнішими були завдання, пов'язані з IAM/OIDC та Terraform state. Найбільше було незрозуміло, чому після видалення ресурсів безпосередньо в AWS Terraform продовжує бачити 
їх у state і під час загального `terraform apply` намагається створити їх заново.

Також хочу додатково повторити IAM trust policies, `terraform import`, `-replace`, `-target` та роботу з infrastructure drift.
