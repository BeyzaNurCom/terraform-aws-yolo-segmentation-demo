# 🚀 YOLO11 Instance Segmentation on AWS with Terraform

Bu proje, **Ultralytics YOLO11 (yolo11n-seg)** modeli kullanan Docker tabanlı bir **Instance Segmentation** web uygulamasının **Terraform (Infrastructure as Code)** kullanılarak AWS üzerinde otomatik olarak dağıtılmasını göstermektedir.

Altyapı; yüksek erişilebilirlik, güvenlik ve tekrar üretilebilirlik hedeflenerek tasarlanmıştır. Uygulama Docker konteyneri içerisinde çalışmakta olup EC2 sunucuları açılış sırasında `user_data.sh` betiği ile otomatik olarak hazırlanmakta ve uygulama herhangi bir manuel kurulum gerektirmeden çalıştırılmaktadır.

---

# 🏗️ Architecture

Altyapı **AWS eu-central-1 (Frankfurt)** bölgesinde iki farklı Availability Zone üzerine kurulmuştur.

- 2 Public Subnet
- 2 Private Subnet
- 2 NAT Gateway
- 2 EC2 Instance
- 1 Application Load Balancer

Application Load Balancer public subnetlerde çalışırken uygulama private subnetlerde bulunan EC2 sunucularında çalışmaktadır.

Private subnetlerde bulunan EC2 instance'ları internete doğrudan açık değildir. İşletim sistemi güncellemeleri, Docker bağımlılıkları ve YOLO11 modeli NAT Gateway üzerinden indirilmektedir.

Application Load Balancer gelen HTTP isteklerini iki EC2 instance arasında dağıtır ve Health Check mekanizması sayesinde yalnızca sağlıklı sunuculara trafik yönlendirir.

Target Group üzerinde **Sticky Sessions (cookie-based)** etkinleştirilmiştir. Böylece aynı kullanıcı oturum süresince aynı EC2 instance'ına yönlendirilmektedir.

### 📊 Architecture Diagram

#### AWS Cloud Architecture

![AWS Cloud Architecture](media/architecture-diagram.png)

#### AWS VPC Resource Map

![AWS VPC Resource Map](media/aws-console-vpc-resource-map.png)

---

# ⚙️ Engineering Decisions

## Sticky Sessions

Flask uygulaması işlenen görüntüleri geçici olarak `static/uploads` dizininde saklamaktadır.

İlk istek EC2-A üzerinde işlendiğinde sonraki isteğin EC2-B'ye yönlendirilmesi durumunda ilgili dosya bulunamayacağından kullanıcı **404 Not Found** hatası alacaktır.

Bu problemi önlemek amacıyla Target Group üzerinde **ALB Cookie Stickiness** etkinleştirilmiştir.

---

## Swap Memory

Projede maliyeti düşük tutmak amacıyla **t3.micro (1 GB RAM)** instance tipi tercih edilmiştir.

Docker image oluşturulurken PyTorch ve diğer bağımlılıkların kurulumu sırasında bellek kullanımı artmaktadır.

Bu nedenle `user_data.sh` içerisinde sistem açılışı sırasında otomatik olarak **4 GB Swap Space** oluşturulmaktadır.

Bu sayede Docker build işlemleri ve model yüklenmesi düşük bellekli instance üzerinde sorunsuz şekilde tamamlanabilmektedir.

---

## Security Groups

Security Group kuralları **Least Privilege Principle** dikkate alınarak hazırlanmıştır.

- Application Load Balancer yalnızca HTTP (80) trafiğini kabul eder.
- EC2 instance'ları internete doğrudan açık değildir.
- EC2 üzerinde çalışan uygulama yalnızca ALB Security Group üzerinden gelen TCP/5000 trafiğini kabul etmektedir.

Bu yapı sayesinde uygulamaya doğrudan EC2 üzerinden erişim mümkün değildir.

---

# 💰 Cost Estimation

Altyapının tahmini maliyeti **Infracost** kullanılarak analiz edilmiştir.

| Resource | Estimated Monthly Cost |
|-----------|----------------------:|
| Application Load Balancer | $19.71 |
| EC2 Instance (t3.micro) | $8.76 |
| EBS Volume (8 GB) | $0.95 |
| **Estimated Total** | **~$29.42 / month** |

> **Note**
>
> Veri transferi ve ALB LCU ücretleri kullanım miktarına bağlı olarak değişmektedir.

Detaylı rapor:

`reports/infracost-report.md`

---

# 🖥️ Application

Flask tabanlı web arayüzü üzerinden kullanıcılar bir görüntü yükleyebilir.

YOLO11 modeli yüklenen görüntü üzerinde instance segmentation işlemini gerçekleştirerek sonucu kullanıcıya sunmaktadır.

### Home Page

![Home Page](media/screenshot-home.png)

### Segmentation Result

![Segmentation Result](media/screenshot-result.png)

---

# 🚀 Deployment

## Run Locally

```bash
cd app

docker build -t yolo-segmentation .

docker run -d -p 5000:5000 yolo-segmentation
```

Uygulama:

```
http://localhost:5000
```

---

## Deploy to AWS

Terraform dizinine geçin.

```bash
cd terraform
```

`terraform.tfvars`

```hcl
ami_id          = "ami-xxxxxxxxxxxxxxxx"
github_repo_url = "https://github.com/<username>/terraform-aws-yolo-segmentation-demo.git"
```

Terraform'u başlatın.

```bash
terraform init
```

Planı inceleyin.

```bash
terraform plan
```

Kaynakları oluşturun.

```bash
terraform apply
```

Kurulum tamamlandıktan sonra Terraform çıktısındaki **Application Load Balancer DNS** adresi üzerinden uygulamaya erişebilirsiniz.

Altyapıyı kaldırmak için:

```bash
terraform destroy
```

---

# 🛠️ Technologies

- Terraform
- Amazon Web Services (VPC, EC2, ALB, NAT Gateway, Security Groups, Elastic IP)
- Docker
- Flask
- Python 3.11
- Ultralytics YOLO11 (yolo11n-seg)
- PyTorch
- OpenCV
- Pillow