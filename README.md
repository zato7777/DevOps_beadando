Felhő és DevOps alapok gyakorlat kötelező program

A fejlesztéshez a korábbi Programrendszerek fejlesztése gyakorlat kötelező programomat használtam fel. Ezen projekt elérése: https://github.com/zato7777/Jegyertekesito.git

A projektet Windowson készítettem, Docker Desktop, Git, Minikube, Terraform, Mongorestore szükséges a telepítéshez, Nodejs a további fejlesztéshez.
A projekt megvalósításában felhasznált eszközök: Jenkins, Minikube, Terraform, Nginx, Prometheus, Grafana.

Az eredeti projekt a MEAN stacken készült, Mongo-t használ adattárolásra, a frontend Angular, a backend NodeJs segítségével készült és ExpressJs szerver framework-öt használ.
A webalkalmazás eseményekre való jegyfoglalást tesz lehetővé és számos funkcióval bír.


A projekt működése:
A projekt komponensei docker konténerekben futnak, melyeket a kubernetes minikube eszköze kezel. A környezetet Terraform kódok írják le.
A backend egy init_container-t alkalmaz, ez blokkolja a backend indítását, amíg a mongo el nem érhető, így elkerülve a connection refused hibákat indítás után például bejelentkezéskor.
A mongo adatbázis adatainak tartós tárolásáról a kubernetes persistent colume claim gondoskodik. Ez leállítás után is visszatölthetővé teszi az adatokat és a változásokat is menti.
A hálózatban a NodePort típusú servicek fix portokat kapnak, ezeket az első indításkor kiadott paranccsal fix localhostos portokra írányíthatunk át.
frontend: 30000 -> 4200
backend: 30001 -> 5000
grafana: 30002 -> 4400
prometheus: 30003 -> 4300
A fejlesztés során a buildelést a Jenkins szerver biztosítja, amely saját imaget használ és szintén egy kubernetes klaszterban fut.
A jenkins imagehez tartozó dockerfile segítségével telepíthetők a szükséges pluginek, a nodejs és terraform toolok hozzáadásra kerülnek.
A buildelésre továbbra is először kézzel fel kell venni a credentielöket és konfigurálni kell a pipeline jobot.
A beállított pipeline segítségével letöltésre kerül a git kód, a függőségek telepítésre kerülnek. A frontend és backend imageket buildeli és feltölti a dockerhubra. A terraform segítségével frissíti a kubernetes klasztert az új verzióval.
A backend implementálja a prometheus(prom-client) könyvtárat és a /metrics végponton folyamatosan publikálja a mért teljesítmény adatokat.
A frontend build folyamat során a NodeJs lefordítja az Angular kódot, majd a kész statikus kódot egy Nginx szerver szolgálja ki a böngészőnek.
A Monitorozást a Prometheus valósítja meg. Egy ConfigMap-ben tárolt konfiguráció mentén 10 másodpercenként lekérdezi a saját és a backend metrikáit. 
A Grafana a Prometheustól kapcsolaton keresztül kapott adatokat vizualizálja. A Grafanában beimportált dashboard szintén mentésre kerül és leállítás után visszatölthető. Ezért szintén egy kubernetes PVC felelős.



A Projekt telepítésének útmutatója:
1. git clone https://github.com/zato7777/DevOps_beadando.git
2. minikube start --driver=docker --ports=8443:8443,4200:30000,5000:30001,4400:30002,4300:30003
3./A terraform mappán belül:
     terraform init
     terraform apply -auto-approve
3/B Használható a Jenkins build now is ugyanerre a célra, ehhez először a Jenkins környezetet kell konfigurálni.

Az adatbázis adatainak visszatöltése a dump könyvtárból:
1. minikube kubectl -- get pods
2. minikube kubectl -- cp ./dump MONGO_POD_NEVE:/tmp/dump
3. minikube kubectl -- exec -it MONGO_POD_NEVE -- mongorestore --db=jegyertekesito /tmp/dump/mongo_db

Jenkins konfigurálása (a build now parancshoz):
1. A jenkins_config mappán belül: docker build -t my-jenkins .
2. docker run -u root -d -p 8080:8080 -p 50000:50000 --name my-jenkins --restart=on-failure -v jenkins_home:/var/jenkins_home -v //var/run/docker.sock:/var/run/docker.sock my-jenkins
A jenkins konfigurálás során a varázsló ki van kapcsolva, ezért nem kéri a jelszót sem.
A Jenkins webes felülete a localhost:8080 cím alatt érhető el.

Kubeconfig.txt:
A minikube telepítése után a felhasználók alá bekerül egy .kube mappa, azon belül található egy config nevű fájl. Mivel a jenkins egy konténerben fut, ezért a benne megadott útvonalakat nem látja.
A következő parancsot kell kiadnunk:
minikube kubectl -- config view --flatten --minify
A kapott eredményt egy txt fájlba kell másolni. Két sort kell ebben módosítani, mielőtt a fájl credentialként megadhatnánk a Jenkinsnek:
1. server: https://127.0.0.1:8443 sort át kell írni: server: https://host.docker.internal:8443 -> a konténer miatt.
2. certificate-authority-data sort erre a sorra cserélni: insecure-skip-tls-verify: true -> a server:... sor módosítása miatt.

Credentials felvétele ezekkel az ID-kal:
1. github-login
2. dockerhub-login
3. kubeconfig

Pipeline Job létrehozás:
-Név: Jegyertekesito-Pipeline, típus: Pipeline
-Poll SCM, Schedule: H/10 * * * *
-Pipeline Definition: Pipeline script from SCM opció, SCM: Git, Repository URL: https://github.com/zato7777/DevOps_beadando.git, Credentials: github-login
-Lightweight checkout: ki kell venni a pipát

Első indítás után a Prometheusban és Grafanaban elvégezhető beállítások:
Prometheus query parancs: process_resident_memory_bytes

Grafana:
1. Fel kell venni egy új connection-t a Prometheussal, itt ezt az url-t kell megadni a Connection beállításnál: http://prometheus-service:9090
2. A connection felvétele után beimportálható egy alap NodeJs-es metrikákat használó dashboard:
- Ehhez a következő kódot kell betölteni: 11159
- A betöltés után data source-ként megadni a korábban felvett Prometheus connection-t

A telepített projekt indítása:
Jenkins indítása: docker start jenkins
Minikube indítása: minikube start

Projekt elérése:
Frontend: http://localhost:4200
Backend: http://localhost:5000/app
Jenkins: http://localhost:8080
Prometheus: http://localhost:4300
Grafana: http://localhost:4400

