# BitGo-Takehome
## 1. System Diagram & Description
<img width="1468" height="692" alt="image" src="https://github.com/user-attachments/assets/c3a7d9b3-8252-420a-8d59-84905557a36e" />

Currently the system has one internet gateway which is connected to https://snubby18.online. From there the traffic is routed through a gateway. The ALB processes the requests and looks at which containers are available accross the instances and directs the request there. Then based on resource utilization which is output to cloud watch (which has a dashboard setup on the aws platform) if averate CPU utilization accross compute units exceeds 50% another instance is provisioned.

## 2. What scales and how it triggers?
The system is currently setup to create new ec2 instances when the average CPU utilization of the currently provisioned resources exceeds 50% and then it is also dynamically reduced when the number goes below this threshold. 

## 3. What I Would Add With Another Week
Since I spent roughly 4 hours on the actual HCL and domain confiuration I stopped there with feature implementation. If I had another week, there would be a few key features that I would implement. 

The first being more robust verification and networking management through the implementation of an istio service mesh to allow for scaling of more microservices being added to the system.

Then I would add ci/cd on the repository itself because that would speed up my deployments. With linting of the HCL, version management/releases, and module management.

The final feature that I would add would be a multi-region deployment of the application for two reasons. Firstly, the delay between when users make a request for the application wouldn't have to be region dependent. Secondly, service/reliability is also region independant. Meaning, in the case say there is a flaw with the deployment in one region, the uptime on the client end isnt affected. However, if there is stateful data associated with the applicaiton, this would bring increased overhead in complexity of how the app is built. 


## 4. What I Cut for Time
The main thing that I cut for time was the lack of integration of a prometheus microservice which reads the metrics from the applications `/metrics` endpoint and exposes it to a grafana dashboard to utilize the records and logs that the application itself records. 


## 5. Engineering Decisions I Made
The first decision I made was to write up the infrastructure to scale with EC2 instances. The reason being that I wanted this system to plug and play with other enterprise services like DataDog, Istio, Promtail, Cilium, and more. Making the system open to that format right now allows for future additions to be easily added to the system. In contrast to the FarGate service provided which is very black box and the cost piles up a lot long term.

As for the computation spec of 0.25 vCPU and 512 MB RAM per container, and the dynamic port mapping on the instances, I chose that to handle the requirement of a burst of many requests for a low computational intensity task would scale up massively under the test condidtions for this assignment. The networking mode of the instances was chosen as bridge to allow for the quick creation of new containers for the task of this go application. 
