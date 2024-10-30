# Supply Chain Management Smart Contract

## About
This Clarity smart contract implements a supply chain management system on the Stacks blockchain. It allows for tracking products from manufacture to sale, with features for quality control, inventory management, and detailed history logging.

## Features

- Product registration
- Ownership transfer
- Status updates
- Quality control
- Inventory management
- Event logging
- Access control

## Contract Functions

### Public Functions

1. `register-product`: Register a new product in the system.
2. `transfer-ownership`: Transfer ownership of a product to a new owner.
3. `update-status`: Update the status of a product.
4. `update-quality`: Update the quality score of a product.
5. `update-quantity`: Update the quantity of a product.

### Read-Only Functions

1. `get-product`: Retrieve information about a specific product.
2. `get-product-history`: Get the history of a product at a specific index.
3. `get-latest-history-index`: Get the latest history index.
4. `get-total-products`: Get the total number of registered products.
5. `product-exists`: Check if a product with a given ID exists.

## Error Codes

- `err-not-authorized` (u100): The caller is not authorized to perform the action.
- `err-product-exists` (u101): Attempt to register a product that already exists.
- `err-product-not-found` (u102): The specified product does not exist.
- `err-invalid-status` (u103): The provided status is not valid.
- `err-invalid-input` (u104): The input provided is invalid or out of acceptable range.

## Security Considerations

- This contract implements access control to ensure that only authorized users can perform certain actions.
- Input validation is performed on all public functions to prevent invalid data from being processed or stored.
- The contract uses Clarity's built-in functions and best practices to ensure security and efficiency.