# Building an End-to-End Data Pipeline with Azure Storage & Azure Data Factory

## 📌 What This Project Is About

This was my hands-on attempt at understanding how Azure actually works under the hood when it comes to moving data around — from setting up basic cloud resources to building a real pipeline that copies a file from one place to another using Azure Data Factory (ADF).

Instead of just reading theory, the goal here was to *do* everything inside the Azure Portal: create a resource group, spin up a storage account, drop a CSV file into a blob container, build an ADF pipeline around it, run it, and then watch it actually execute and validate the metadata. Basically, a small but complete simulation of how data engineers move files in the real world.

For the dataset, I used the **Superstore dataset** from Kaggle ([link](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)) — a nice, simple CSV that's perfect for testing a copy pipeline without overcomplicating things.

---

## 🎯 Objective

- Get comfortable navigating the Azure Portal
- Understand how Resource Groups, Storage Accounts, and Containers fit together
- Learn the Azure Data Factory interface (Author / Monitor / Manage)
- Build linked services and datasets to connect ADF with Blob Storage
- Use the **Get Metadata** activity to inspect file details before processing
- Build and run a **Copy Data** pipeline (source → destination)
- Understand IAM roles (Reader, Contributor) and how access control works between ADF and Storage
- Put it all together into one working end-to-end pipeline with metadata validation

---

## 🛠️ Tools & Services Used

| Service | Purpose |
|---|---|
| **Azure Resource Group** | Logical container to keep all related resources organized |
| **Azure Storage Account** | Hosts the blob container where source/destination data lives |
| **Blob Container** | Stores the CSV file (source and destination folders) |
| **Azure Data Factory (ADF)** | Orchestrates the pipeline — connects, copies, and validates data |
| **IAM (Identity & Access Management)** | Controls who/what can access the storage resources |

---

## 🚀 Step-by-Step Walkthrough

### 1. Exploring the Azure Portal & Creating a Resource Group
First things first — I logged into the Azure Portal and got familiar with the dashboard layout (it's a lot to take in at first!). I created a new **Resource Group** to act as the "folder" that would hold every resource I'd create for this project. Keeping everything under one resource group makes it way easier to manage and clean up later.

---

### 2. Creating a Storage Account & Blob Container
Next, I created a **Storage Account** inside that resource group. Once it was up, I went into it and created a **Blob Container** — this is essentially the "bucket" where files get stored.

I then uploaded the **Superstore CSV file** into the container (in a `source` folder/path), which would later act as the input for our pipeline.

---

### 3. Creating Azure Data Factory & Exploring the ADF UI
With storage ready, I created an **Azure Data Factory** resource and opened up its Studio interface. This is where the real fun starts. I spent some time just clicking around to understand the three main areas:

- **Author** – where you build pipelines, datasets, and data flows
- **Monitor** – where you track pipeline runs, see success/failure, and debug issues
- **Manage** – where linked services, IAM, and global settings live

---

### 4. Creating a Linked Service & Datasets
To let ADF actually "talk" to my storage account, I created a **Linked Service** pointing to the Blob Storage account. Authentication was done using the storage account key (the simplest option for learning purposes).

Then I created two **datasets**:
- A **source dataset** pointing to the CSV file in the `source` folder
- A **destination (sink) dataset** pointing to an empty `destination` folder in the same container

---

### 5. Using the Get Metadata Activity
Before jumping straight into copying data, I added a **Get Metadata** activity to the pipeline. This activity reads information about the source file — things like file name, size, and last modified timestamp — without actually moving any data.

This step is super useful in real pipelines because it lets you validate that a file *exists* and is *ready* before you process it (basically a sanity check before doing the heavy lifting).

---

### 6. Building the Pipeline with Copy Data Activity
Now for the main event — I added a **Copy Data** activity to the pipeline:

- **Source**: the Superstore CSV from the blob container
- **Sink/Destination**: a new file (or folder) in the destination path of the same container

I configured the source and sink settings (file format = DelimitedText/CSV, with the right delimiter and header settings), connected it after the Get Metadata activity, and arranged the pipeline flow logically.

---

### 7. Running the Pipeline (Debug & Trigger) + Monitoring
I ran the pipeline first in **Debug mode** to test it without publishing — this helps catch errors quickly. Once it ran successfully, I also tried triggering it manually to simulate a "production" run.

Then I switched over to the **Monitor** tab to watch the pipeline execution in real time — checking the status (Succeeded ✅), duration, and drilling into each activity to see input/output details.

---

### 8. Setting Up IAM Roles (Reader & Contributor)
To understand access control, I went into the **IAM (Access Control)** section of the storage account and assigned roles:

- **Reader** – read-only access to view resource configuration
- **Contributor** – ability to manage and modify resources (used to give ADF's managed identity access to read/write blobs)

This step matters a lot in real-world setups because it controls exactly what ADF (or any user/service) is allowed to do with the storage account — following the principle of least privilege.

---

### 9. Final End-to-End Pipeline
With everything connected, the final pipeline does this:

```
Blob Storage (source CSV)
        │
        ▼
Get Metadata Activity (validates file exists & checks properties)
        │
        ▼
Copy Data Activity (copies CSV to destination path)
        │
        ▼
Blob Storage (destination CSV)
```

Running this end-to-end confirmed that the file was successfully validated and copied, completing the full **Blob → ADF → Destination** flow.

---

## ✅ Pipeline Execution Results

- Pipeline Status: **Succeeded**
- Get Metadata Activity: Returned file name, size, and last modified date correctly
- Copy Data Activity: Successfully copied the CSV from source to destination folder
- Destination container: New file visible and matches the source file in size/content

---

## 🧠 Summary & What I Learned

Honestly, this assignment made a lot of "cloud data engineering" concepts click that previously felt abstract. A few things that stood out:

- **Resource Groups are just organizational containers** — they don't do anything themselves, but they make managing related resources so much easier.
- **Storage Accounts and Containers** are basically Azure's version of cloud file storage (similar to S3 buckets if you've used AWS).
- **ADF's Author/Monitor/Manage split** makes a lot of sense once you use it — you build in Author, watch results in Monitor, and configure connections/security in Manage.
- The **Get Metadata activity** is a small but powerful tool — adding a validation step before processing data is a really common (and smart) pattern in real pipelines.
- **IAM roles** are not just a security checkbox — they directly determine whether your pipeline can even access the data it needs. Getting a "Forbidden" error because of missing permissions was a great (if slightly frustrating) learning moment!
- Seeing the pipeline go from "Debug run" to "Succeeded" status in the Monitor tab was honestly pretty satisfying — it felt like the first real "it works!" moment of the project.

Overall, this was a great low-stakes way to get comfortable with the Azure ecosystem and understand how the pieces — storage, compute/orchestration (ADF), and security (IAM) — all fit together to move data from point A to point B.

---

## 📚 Resources Used

- Dataset: [Superstore Dataset – Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)
- Assignment Reference Document: Provided via Celebal Technologies LMS (SharePoint)

---

## 📁 Repository Structure (Suggested)

```
Week 4/
├── README.md
├── Resource Group.png
├── source-data container.png
├── ds_source_csv dataset.png
├── ds_destination_csv dataset.png
├── Linked Service.png
├── Linked Service 2.png
├── Get Metadata activity configuration.png
├── Get Metadata activity configuration 2.png
├── pipeline design.png
├── IAM Role assignment.png
├── IAM Role assignment 2.png
├── IAM Role assignment 3.png
└── Mini Project Successful.png
```
