# 🚀 YOLO11 Instance Segmentation Demo (Terraform & AWS Deployment)

Bu proje, son teknoloji **YOLO11 (yolo11n-seg)** modelini kullanan konteynerize (Docker) bir **örnek bölütleme (Instance Segmentation)** web uygulamasının AWS üzerinde yüksek kullanılabilirliğe (High Availability) sahip ve güvenli bir altyapıda **Terraform (IaC)** ile otomatik olarak canlıya alınmasını sağlar.

Bu çalışma, modern bulut mimarisi tasarımı, konteyner teknolojileri, IaC (Infrastructure as Code) pratikleri ve makine öğrenimi modeli entegrasyonunu uçtan uca göstermek amacıyla geliştirilmiştir.

---

## 🏗️ Sistem Mimarisi ve Ağ Tasarımı

Uygulamanın AWS üzerindeki altyapısı, kurumsal düzeyde güvenlik ve yedeklilik standartları (Best Practices) göz önünde bulundurularak tasarlanmıştır:

*   **Multi-AZ VPC Mimarisi:** AWS `eu-central-1` (Frankfurt) bölgesinde 2 adet Kullanılabilirlik Alanına (Availability Zone - AZ) yayılmış VPC mimarisi.
*   **Public ve Private Subnet Ayrımı:** 
    *   **Public Subnetler:** Dış dünyaya açık olan **Application Load Balancer (ALB)** ve internet çıkışı sağlayan **NAT Gateway**'leri barındırır.
    *   **Private Subnetler:** Web uygulamasını çalıştıran **EC2** sunucularını barındırır. Bu sayede sunucular internetten doğrudan erişilemez hale getirilerek maksimum güvenlik sağlanır.
*   **Yüksek Kullanılabilirlikli NAT Gateways:** Her AZ için bağımsız bir NAT Gateway kurulmuştur. Böylece bir AZ'de kesinti yaşansa dahi, diğer AZ'deki EC2 sunucuları güvenli bir şekilde internete erişip paket güncellemelerini, Docker imaj bağımlılıklarını ve YOLO modelini indirmeye devam edebilir.
*   **Application Load Balancer (ALB):** Public subnetlerde konumlandırılmış olup gelen HTTP trafiğini private subnetlerdeki EC2 sunucularına dengeli bir şekilde dağıtır.
*   **Stickiness (Oturum Bağlılığı):** ALB üzerinde target group seviyesinde **sticky sessions (cookie-based)** aktif edilmiştir (Detayları aşağıda açıklanmıştır).

### 📊 Mimari Şemalar

#### 1. AWS Cloud Altyapı Mimarisi
![AWS Cloud Altyapı Mimarisi](media/architecture-diagram.png)

#### 2. AWS VPC Kaynak Haritası (VPC Resource Map)
![AWS VPC Kaynak Haritası](media/aws-console-vpc-resource-map.png)

---

## 🛠️ Kritik Mimari Kararlar ve DevOps Çözümleri

Projenin üretim ortamı (production-ready) standartlarına uygun olmasını sağlayan temel mühendislik kararları şunlardır:

### 1. ALB Sticky Sessions (Oturum Yapışkanlığı) Tercihi
*   **Problem:** Flask web uygulaması, yüklenen görselleri işleyip sonuçları yerel disk üzerindeki `static/uploads` klasörüne kaydetmektedir. 
*   **Çözüm:** Arkada iki adet EC2 instance çalıştığı için, kullanıcı görseli yüklediğinde istek EC2-A'ya gidebilir ve görsel orada işlenir. Kullanıcı sonucu görmek istediğinde ALB sonraki isteği EC2-B'ye yönlendirirse, EC2-B'de bu dosya bulunamayacağı için uygulama `404 Not Found` hatası verecektir. Bu durumu çözmek için hedef grubunda (target group) **Sticky Sessions (lb_cookie)** aktif edilmiştir. Bu sayede kullanıcı, oturum süresince (3600 saniye) aynı EC2 instance'ına yönlendirilir ve kesintisiz bir deneyim sunulur.

### 2. EC2 Swap Bellek (Swap Space) Yönetimi (4GB)
*   **Problem:** Projenin baseline maliyetini düşük tutmak amacıyla **t3.micro (1GB RAM)** instance tipi seçilmiştir. Ancak, PyTorch tabanlı YOLO11 modelinin yüklenmesi, pip bağımlılıklarının kurulması ve Docker imajının sunucuda build edilmesi aşamalarında 1GB RAM yetersiz kalmakta ve sunucu Out-Of-Memory (OOM) hatasıyla kilitlenmektedir.
*   **Çözüm:** EC2 sunucusu başlatılırken çalışan `user_data.sh` betiğinde dinamik olarak **4GB Swap Alanı** oluşturulup sisteme monte edilmiştir. Bu sayede, t3.micro gibi maliyet etkin bir sunucuda bellek aşımı yaşanmadan Docker build ve model çıkarım (inference) işlemleri sorunsuz bir şekilde tamamlanabilmektedir.

### 3. En Düşük Yetki İlkesi (Least Privilege Security Groups)
*   EC2 güvenlik grubu (Security Group), dış dünyadan gelen tüm giriş isteklerine kapatılmıştır. Yalnızca ALB'nin güvenlik grubundan gelen ve uygulamanın çalıştığı **5000** portundaki TCP trafiğine izin verilir. Bu sayede sunucu seviyesinde saldırı yüzeyi minimuma indirilmiştir.

---

## 💰 Bulut Maliyet Analizi (Infracost)

Bulut maliyetlerinin optimize edilmesi ve şeffaflığı amacıyla altyapı **Infracost** ile analiz edilmiştir. Baseline mimari için tahmini aylık çalışma maliyeti yaklaşık **$29.42**'dir (dinamik veri transferi ve LCU kullanım ücretleri hariç):

| Kaynak (Resource) | Detay | Aylık Miktar | Birim | Aylık Tahmini Maliyet |
| :--- | :--- | :---: | :---: | :---: |
| **Application Load Balancer** | ALB Çalışma Süresi | 730 | Saat | $19.71 |
| **Application Load Balancer LCU** | ALB Kapasite Birimi | Kullanıma Bağlı | LCU | ~$5.84 (LCU başına) |
| **EC2 Instance** | t3.micro Linux/UNIX (On-Demand) | 730 | Saat | $8.76 |
| **EC2 Root Volume** | General Purpose SSD (gp2 - 8GB) | 8 | GB | $0.95 |
| **Toplam Baseline Maliyet** | | | | **~$29.42 / Ay** |

> [!NOTE]
> Detaylı maliyet raporuna [reports/infracost-report.md](reports/infracost-report.md) dosyasından ulaşabilirsiniz.

---

## 🖥️ Web Uygulaması ve Kullanıcı Arayüzü

Flask, OpenCV ve PyTorch tabanlı web arayüzü modern, temiz ve duyarlı (responsive) bir tasarım diline sahiptir. Kullanıcılar görsel yükleyerek YOLO11 modelinin nesneleri nasıl piksel hassasiyetinde segmentlere ayırdığını canlı olarak görebilirler.

#### 1. Ana Sayfa (Görsel Yükleme Paneli)
![Ana Sayfa](media/screenshot-home.png)

#### 2. Segmentasyon Sonucu ve İndirme Ekranı
![Segmentasyon Sonucu](media/screenshot-result.png)

---

## 🚀 Kurulum ve Canlıya Alma (Deployment Guide)

### 🏠 1. Yerel Ortamda Çalıştırma (Docker)

Projeyi yerel makinenizde test etmek için Docker kullanabilirsiniz:

```bash
# Projenin app klasörüne gidin
cd app

# Docker imajını oluşturun
docker build -t yolo-segmentation-app .

# Konteyneri çalıştırın
docker run -d -p 5000:5000 yolo-segmentation-app
```
Uygulamaya tarayıcınızdan `http://localhost:5000` adresinden erişebilirsiniz.

### ☁️ 2. AWS Üzerinde Terraform ile Canlıya Alma

#### Gereksinimler:
*   AWS CLI yüklü ve yetkilendirilmiş (AdministratorAccess veya gerekli IAM izinleri).
*   Terraform (v1.0.0+) yüklü.

#### Adımlar:
1.  `terraform` dizinine geçin:
    ```bash
    cd terraform
    ```
2.  `terraform.tfvars` dosyasını oluşturun veya mevcut olanı düzenleyin. İçeriğine AWS AMI kimliğini ve projenizin GitHub depo URL'sini girin:
    ```hcl
    ami_id          = "ami-xxxxxxxxxxxxxxxxx" # Amazon Linux 2023 AMI ID
    github_repo_url = "https://github.com/kullanici_adiniz/terraform-aws-yolo-segmentation-demo.git"
    ```
3.  Terraform projesini başlatın:
    ```bash
    terraform init
    ```
4.  Oluşturulacak kaynakların planını inceleyin:
    ```bash
    terraform plan
    ```
5.  Altyapıyı AWS üzerinde oluşturun (onaylamak için `yes` yazın):
    ```bash
    terraform apply
    ```
6.  İşlem tamamlandığında Terraform size ALB'nin DNS adresini (`alb_dns_name`) çıktı olarak verecektir. Bu adresi tarayıcınıza yapıştırarak uygulamanızı test edebilirsiniz.

---

## 🛠️ Kullanılan Teknolojiler

*   **IaC (Infrastructure as Code):** Terraform
*   **Bulut Platformu (Cloud):** Amazon Web Services (AWS) - VPC, EC2, ALB, NAT Gateway, Elastic IP, Security Groups
*   **Derin Öğrenme / AI:** Ultralytics YOLO11 (yolo11n-seg), PyTorch
*   **Görüntü İşleme:** OpenCV (opencv-python-headless), Pillow
*   **Web Framework & Sunucu:** Flask (Python 3.11), Docker Container
