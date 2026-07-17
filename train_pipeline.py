import os
import zipfile
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader

# ==========================================
# Google Colab Setup / Dependency check
# ==========================================
# If running on a new Google Colab environment, you can install dependencies via:
# !pip install pandas numpy torch

# ==========================================
# Configuration & Paths
# ==========================================
WEIGHTS_ZIP_PATH = os.path.join('assets', 'model', 'model_weights.zip')
EXTRACT_DIR = os.path.join('assets', 'model', 'extracted_weights')
DATASET_CSV_PATH = 'dataset.csv'

BATCH_SIZE = 32
LEARNING_RATE = 0.001
EPOCHS = 10
DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')


def unzip_model_weights(zip_path, extract_to):
    """
    Unzips the master model weights from the assets folder.
    If the zip file does not exist, prints a warning and proceeds
    with random initialization.
    """
    if not os.path.exists(zip_path):
        print(f"[!] Warning: Master weights zip file not found at '{zip_path}'.")
        print("    The pipeline will initialize model weights randomly.")
        return False

    print(f"[*] Extracting master weights from '{zip_path}' to '{extract_to}'...")
    try:
        os.makedirs(extract_to, exist_ok=True)
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
        print("[+] Model weights extracted successfully.")
        return True
    except Exception as e:
        print(f"[x] Error occurred during extraction: {e}")
        return False


class SoilDataset(Dataset):
    """
    Custom PyTorch Dataset for loading Soil properties.
    If the specified CSV file doesn't exist, it generates a dummy CSV
    so the template can run end-to-end out of the box.
    """
    def __init__(self, csv_path):
        self.csv_path = csv_path
        
        # Check and create dummy dataset if missing
        if not os.path.exists(csv_path):
            print(f"[!] Warning: Dataset CSV not found at '{csv_path}'.")
            print("    Creating a synthetic dataset CSV for demo/testing...")
            self._generate_dummy_csv(csv_path)

        self.df = pd.read_csv(csv_path)
        
        # Assuming the CSV has features in all columns except the last one,
        # and the last column is the target class (soil classification label).
        self.features = self.df.iloc[:, :-1].values.astype(np.float32)
        
        target_col = self.df.iloc[:, -1].values
        # Encode target strings to integers to avoid crash (Problem 4)
        if target_col.dtype == object or (len(target_col) > 0 and isinstance(target_col[0], str)):
            unique_labels = sorted(list(set(target_col)))
            label_to_idx = {label: idx for idx, label in enumerate(unique_labels)}
            print(f"[INFO] Categorical targets detected. Encoding labels: {label_to_idx}")
            self.targets = np.array([label_to_idx[val] for val in target_col], dtype=np.int64)
        else:
            self.targets = target_col.astype(np.int64)

    def _generate_dummy_csv(self, path):
        # 100 samples, 5 hypothetical features: Nitrogen, Phosphorus, Potassium, pH, Moisture
        np.random.seed(42)
        data = np.random.randn(100, 5)
        # Class labels: 0, 1, or 2 (representing different soil types)
        labels = np.random.randint(0, 3, size=(100, 1))
        dataset = np.hstack((data, labels))
        
        columns = ['nitrogen', 'phosphorus', 'potassium', 'ph', 'moisture', 'soil_type']
        df = pd.DataFrame(dataset, columns=columns)
        df['soil_type'] = df['soil_type'].astype(int)
        df.to_csv(path, index=False)
        print(f"[+] Synthetic dataset saved to '{path}'.")

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):
        return torch.tensor(self.features[idx]), torch.tensor(self.targets[idx])


class SoilClassifier(nn.Module):
    """
    Template Neural Network for Soil Classification.
    Modify the input_dim and num_classes to fit your specific dataset.
    """
    def __init__(self, input_dim, num_classes):
        super(SoilClassifier, self).__init__()
        self.network = nn.Sequential(
            nn.Linear(input_dim, 64),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, num_classes)
        )

    def forward(self, x):
        return self.network(x)


def train_model(model, dataloader, criterion, optimizer, epochs, device):
    """
    Standard PyTorch training loop.
    """
    # Model placement is done in main before optimizer creation (Problem 1)
    print(f"[*] Starting training loop on device: {device.type.upper()}")
    
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0
        
        for inputs, targets in dataloader:
            inputs, targets = inputs.to(device), targets.to(device)
            
            # Forward pass
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            
            # Backward pass and optimization
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
            
            # Statistics
            running_loss += loss.item() * inputs.size(0)
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()
            
        epoch_loss = running_loss / total
        epoch_acc = (correct / total) * 100
        print(f"Epoch {epoch+1:02d}/{epochs:02d} | Loss: {epoch_loss:.4f} | Accuracy: {epoch_acc:.2f}%")
        
    print("[+] Model training completed.")


def main():
    print("==================================================")
    print("           Soil AI Model Training Pipeline        ")
    print("==================================================")
    
    # 1. Unzip weights (if zip exists)
    unzip_model_weights(WEIGHTS_ZIP_PATH, EXTRACT_DIR)
    
    # 2. Load dataset
    print(f"[*] Loading dataset from '{DATASET_CSV_PATH}'...")
    dataset = SoilDataset(DATASET_CSV_PATH)
    dataloader = DataLoader(dataset, batch_size=BATCH_SIZE, shuffle=True)
    
    # Extract dimensions dynamically from the loaded dataset
    sample_features, _ = dataset[0]
    input_dim = sample_features.shape[0]
    # Calculate classes based on max label to avoid out of bounds in CrossEntropyLoss (Problem 2)
    num_classes = int(np.max(dataset.targets) + 1)
    
    print(f"[+] Loaded {len(dataset)} samples.")
    print(f"    Features per sample: {input_dim}")
    print(f"    Number of classes: {num_classes}")
    
    # 3. Instantiate model and move to DEVICE BEFORE creating the optimizer (Problem 1)
    model = SoilClassifier(input_dim=input_dim, num_classes=num_classes)
    model.to(DEVICE)
    
    # 4. Load weights if they exist in EXTRACT_DIR independently of whether zip is present (Problem 3)
    weights_file = os.path.join(EXTRACT_DIR, 'base_weights.pth')
    if os.path.exists(weights_file):
        print(f"[*] Loading pre-trained base weights from '{weights_file}'...")
        try:
            state_dict = torch.load(weights_file, map_location=DEVICE)
            model_state = model.state_dict()
            
            # Handle shape mismatches gracefully (Problem 5)
            filtered_state_dict = {}
            mismatched_keys = []
            for k, v in state_dict.items():
                if k in model_state and model_state[k].shape == v.shape:
                    filtered_state_dict[k] = v
                else:
                    mismatched_keys.append(k)
            
            if mismatched_keys:
                print(f"[!] Warning: Mismatch detected for layers {mismatched_keys}. Skipping these layers.")
            
            model.load_state_dict(filtered_state_dict, strict=False)
            print("[+] Pre-trained weights loaded successfully.")
        except Exception as e:
            print(f"[!] Could not load weights: {e}. Starting from scratch.")
    else:
        print(f"[!] No 'base_weights.pth' found at '{weights_file}'. Starting from scratch.")
            
    # 5. Define Loss Function and Optimizer
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)
    
    # 6. Run the Training Loop
    train_model(model, dataloader, criterion, optimizer, EPOCHS, DEVICE)
    
    # 7. Save the newly trained model weights
    save_filename = 'trained_soil_model.pth'
    save_path = os.path.join(EXTRACT_DIR, save_filename)
    os.makedirs(os.path.dirname(save_path), exist_ok=True)
    
    try:
        torch.save(model.state_dict(), save_path)
        print(f"[+] Model weights saved to '{save_path}'")
    except Exception as e:
        print(f"[x] Failed to save trained model weights: {e}")
        
    print("==================================================")


if __name__ == '__main__':
    main()
