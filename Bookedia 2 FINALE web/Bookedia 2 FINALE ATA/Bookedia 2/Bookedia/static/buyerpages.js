

// para sa shop now
document.getElementById('shop_btn').addEventListener('click', function() {
const targetSection = document.getElementById('discover_section');
const navbarHeight = document.querySelector('nav').offsetHeight;


const extraPadding = 80; 


const sectionPosition = targetSection.getBoundingClientRect().top + window.pageYOffset - navbarHeight - extraPadding;


window.scrollTo({
    top: sectionPosition,
    behavior: 'smooth'
});
});



    // Toggle dropdown visibility
function toggleDropdown() {
const dropdown = document.getElementById('userDropdown');
dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
}

// Close dropdown when clicking outside
window.onclick = function (event) {
if (!event.target.matches('.usercon-icon')) {
const dropdown = document.getElementById('userDropdown');
if (dropdown.style.display === 'block') {
  dropdown.style.display = 'none';
}
}
};

    document.addEventListener('DOMContentLoaded', function() {
const leftArrow = document.querySelector('.left-arrow');
const rightArrow = document.querySelector('.right-arrow');
const productContainer = document.querySelector('.products');

// Define how far the products scroll when clicking the arrows
const scrollAmount = 400; // Adjust as needed

// Scroll left when clicking the left arrow
leftArrow.addEventListener('click', () => {
    productContainer.scrollBy({
        left: -scrollAmount,
        behavior: 'smooth'
    });
});

// Scroll right when clicking the right arrow
rightArrow.addEventListener('click', () => {
    productContainer.scrollBy({
        left: scrollAmount,
        behavior: 'smooth'
    });
});
});
// para sa trending lang




// para lumabas and descript
document.addEventListener('DOMContentLoaded', function() {
const products = document.querySelectorAll('.product'); // Select all product boxes

products.forEach(product => {
    const toggleButton = product.querySelector('.toggle-description-button'); // Select the toggle button
    const description = product.querySelector('.product-description'); // Select the product description

    toggleButton.addEventListener('click', function(event) {
        // Prevent event propagation to other elements
        event.stopPropagation(); 

        // Hide all other product descriptions
        products.forEach(p => {
            const desc = p.querySelector('.product-description');
            desc.style.display = 'none'; // Hide other descriptions
        });

        // Toggle the display of the clicked product's description
        if (description.style.display === 'none' || description.style.display === '') {
            description.style.display = 'block'; // Show description
        } else {
            description.style.display = 'none'; // Hide description
        }
    });
});
});


// description for the discover part
document.addEventListener('DOMContentLoaded', function() {
const discoverProducts = document.querySelectorAll('.discoverproduct-box'); // Select all product boxes in Discover Section

discoverProducts.forEach(product => {
    const toggleButton = product.querySelector('.btn-show-description'); // Select the toggle button
    const description = product.querySelector('.product-description'); // Select the product description

    toggleButton.addEventListener('click', function(event) {
        // Prevent event propagation to other elements
        event.stopPropagation(); 

        // Hide all other product descriptions
        discoverProducts.forEach(p => {
            const desc = p.querySelector('.product-description');
            desc.style.display = 'none'; // Hide other descriptions
        });

        // Toggle the display of the clicked product's description
        if (description.style.display === 'none' || description.style.display === '') {
            description.style.display = 'block'; // Show description
        } else {
            description.style.display = 'none'; // Hide description
        }
    });
});
});






function showAddingCard() {
document.getElementById('addingCardPopup').style.display = 'flex'; // Show the modal
document.getElementById('overlay').style.display = 'block'; // Show overlay
}

// Function to hide the modal
function hideAddingCard() {
document.getElementById('addingCardPopup').style.display = 'none';
document.getElementById('overlay').style.display = 'none'; // Hide overlay
}

// Close modal when clicking outside of it
document.getElementById('overlay').addEventListener('click', function(event) {
// Check if the click is on the overlay, not on the modal itself
const modal = document.getElementById('addingCardPopup');
if (event.target === this) {
    hideAddingCard();
}
});



document.addEventListener('DOMContentLoaded', function() {
// Get all the Add to Cart buttons
document.querySelectorAll('.add-to-cart-button').forEach(button => {
    button.addEventListener('click', function() {
        // Get the product data from the button attributes
        const productName = this.getAttribute('data-product-name');
        const productImage = this.getAttribute('data-product-image');
        const productPrice = this.getAttribute('data-product-price');

        // Update the modal with the product details
        document.getElementById('popupProductName').textContent = productName;

        // Clear previous image and set new image
        const imageContainer = document.getElementById('adding-image_container');
        imageContainer.innerHTML = ''; // Clear previous image
        const imgTag = document.createElement('img');
        imgTag.src = productImage;
        imgTag.alt = productName;
        imgTag.style.width = '100%'; // Adjust as necessary
        imageContainer.appendChild(imgTag); // Append the new image

        document.getElementById('popupProductPrice').textContent = `₱ ${productPrice}`;
        
        // Reset quantity field to 1
        document.getElementById('quantityInput').value = 1;

        // Display the modal
        document.getElementById('addingCardPopup').style.display = 'block';
    });
});

// Logic to add the item to the cart
document.getElementById('addToCart').addEventListener('click', function(event) {
    event.preventDefault();

    const productName = document.getElementById('popupProductName').innerText;
    const quantity = parseInt(document.getElementById('quantityInput').value);
    const priceText = document.getElementById('popupProductPrice').innerText;

    // Replace the currency symbol correctly
    const price = parseFloat(priceText.replace('₱', '').trim());

    // Get the image source from the img tag
    const productImage = document.querySelector('#adding-image_container img').src;

// Extract the filename from the image URL
const imageFilename = productImage.substring(productImage.lastIndexOf('/') + 1);

    // Check for null values
    if (!productName || quantity <= 0 || isNaN(price)) {
        alert('Please fill in all required fields correctly.');
        console.log('Check values - Product Name:', productName, 'Quantity:', quantity, 'Price:', price);
        return;  // Exit if any values are invalid
    }

    const totalPrice = (price * quantity).toFixed(2); // Calculate total price

    // Create the data object without userSurname
    const cartData = {
        product_name: productName,
        quantity: quantity,
        price: price,
        product_image: imageFilename
    };

    // Send the data to the backend using fetch
fetch('/add_to_cart', {
method: 'POST',
headers: {
    'Content-Type': 'application/json'
},
body: JSON.stringify(cartData)
})
.then(response => response.json())
.then(data => {
if (data.success) {
    console.log('Product added to cart');
    Swal.fire({
        icon: 'success',
        title: 'Success!',
        text: 'Product added to cart successfully!',
        confirmButtonText: 'OK'
    });
    // Reset quantity field and hide modal
    document.getElementById('quantityInput').value = 1;
    hideAddingCard(); // Close the modal
} else {
    console.error(data.error);
    Swal.fire({
        icon: 'error',
        title: 'Error!',
        text: data.error,
        confirmButtonText: 'OK'
    });
}
})
.catch(error => {
console.error('Error:', error);
Swal.fire({
    icon: 'error',
    title: 'Error!',
    text: 'An error occurred while adding to cart.',
    confirmButtonText: 'OK'
});
});

});
});

// BUY NOW
document.addEventListener('DOMContentLoaded', function () {
document.querySelectorAll('.btn-buy-now').forEach(button => {
    button.addEventListener('click', function () {
        const productName = this.getAttribute('data-product-name');
        const productImage = this.getAttribute('data-product-image');
        const productPrice = parseFloat(this.getAttribute('data-product-price'));

        const cartProductContainer = document.getElementById('cartProductContainer');
        cartProductContainer.innerHTML = '';

        const productDiv = document.createElement('div');
        productDiv.classList.add('checkout-product');
        productDiv.innerHTML = `
            <img src="${productImage}" alt="${productName}" style="width: 100px; height: auto;" />
            <div>
                <span>${productName}</span><br>
                <label class="price small">₱ ${productPrice.toFixed(2)}</label>
            </div>
            <input type="number" min="1" value="1" class="quantity-input" />
        `;
        cartProductContainer.appendChild(productDiv);

        const quantityInput = productDiv.querySelector('.quantity-input');
        quantityInput.addEventListener('input', function () {
            const newTotal = productPrice * parseInt(quantityInput.value);
            updateSubtotal(newTotal);
        });

        // Set initial subtotal and show master container
        updateSubtotal(productPrice);
        document.querySelector('.master-container').style.display = 'block';
    });
});

function updateSubtotal(price) {
    const shippingFee = 50.00;
    const total = price + shippingFee;
    document.getElementById('cartSubtotal').textContent = `₱ ${price.toFixed(2)}`;
    document.getElementById('checkoutTotal').textContent = `₱ ${total.toFixed(2)}`;
}
function closePopup() {
document.getElementById('popupContainer').style.display = 'none';
}






// Checkout Button: Store data and redirect
document.querySelector('.checkout-btn').addEventListener('click', function () {
const productName = document.querySelector('.checkout-product span').textContent;
const quantity = parseInt(document.querySelector('.quantity-input').value);
const subtotal = parseFloat(document.getElementById('cartSubtotal').textContent.replace('₱ ', ''));
const shippingFee = 50.00;
const totalPrice = subtotal + shippingFee;

// Store data in sessionStorage
sessionStorage.setItem('orderData', JSON.stringify({
    productName: productName,
    quantity: quantity,
    subtotal: subtotal,
    shippingFee: shippingFee,
    totalPrice: totalPrice
}));

// Redirect to the place order page
window.location.href = '/place_order';
});
});







// para di maka checkout pag wala
document.getElementById('checkout-btn').addEventListener('click', () => {
const selectedItems = [...document.querySelectorAll('.item-checkbox:checked')].map(cb => cb.dataset.itemId);
if (selectedItems.length === 0) {
    alert('Please select at least one item to checkout.');
    return;
}

// Create a query string with selected items
const queryString = selectedItems.map(id => `itemId=${id}`).join('&');

// Redirect to the place_order.html page with selected items
window.location.href = `/place_order?${queryString}`;
});



// message

document.querySelectorAll('.message-seller-button').forEach(button => {
    button.addEventListener('click', function() {
        const productId = this.getAttribute('data-product-id');
        const sellerId = this.getAttribute('data-seller-id');
        
        console.log(`Redirecting to inquire page with product ID: ${productId}, seller ID: ${sellerId}`); // Add this for debugging

        // Redirect to inquire.html with query parameters
        window.location.href = `/inquire?product_id=${productId}&seller_id=${sellerId}`;
    });
});

function openInquireForm(productId, productName, sellerId) {
    // Redirect to the inquire page with query parameters
    window.location.href = `/inquire.html?product_id=${productId}&product_name=${encodeURIComponent(productName)}&seller_id=${sellerId}`;
}
document.addEventListener('DOMContentLoaded', function () {
        // Check for flashed messages
        const successMessage = "{{ get_flashed_messages(with_categories=True) | tojson | safe }}";
        const errorMessage = "{{ get_flashed_messages(with_categories=True) | tojson | safe }}";

        // If there are messages, show them
        if (successMessage) {
            successMessage.forEach(function (msg) {
                Swal.fire({
                    title: msg[0] === 'success' ? 'Success!' : 'Error!',
                    text: msg[1],
                    icon: msg[0] === 'success' ? 'success' : 'error',
                    confirmButtonText: 'OK'
                });
            });
        }
    });


// search
document.getElementById('search-input').addEventListener('input', function() {
const query = this.value;
console.log(`Searching for: ${query}`); // Log the current search query

if (query.length > 0) {
    fetch(`/search?query=${query}`)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            console.log('Search results:', data); // Log the returned search results
            const searchResults = document.getElementById('search-results');
            searchResults.innerHTML = ''; // Clear previous results
            
            if (data.length > 0) {
                data.forEach(product => {
                    const productDiv = document.createElement('div');
                    productDiv.classList.add('product');
                    productDiv.innerHTML = `
                        <img src="${product.product_image}" alt="${product.product_name}" style="width: 200px; height: 200px;">
                        <div class="content">
                            <h3>${product.product_name}</h3>
                            <p>₱ ${product.product_price}</p>
                            <p class="product-description">${product.product_description}</p>
                        </div>
                        <div class="button-container">
                            <button class="add-to-cart-button" data-product-name="${product.product_name}"
                                data-product-image="${product.product_image}"
                                data-product-price="${product.product_price}">Add to Cart</button>
                            <button class="btn-buy-now" data-product-name="${product.product_name}"
                                data-product-image="${product.product_image}"
                                data-product-price="${product.product_price}">Buy Now</button>
                            <button class="message-seller-button" 
                                data-product-id="${product.id}" 
                                data-seller-id="${product.seller_id}"
                                onclick="openInquireForm('${product.id}', '${product.product_name}')">Message Seller</button>
                        </div>
                    `;
                    searchResults.appendChild(productDiv);
                });
                searchResults.style.display = 'block'; // Show the search results
                document.getElementById('products-container').style.display = 'none'; // Hide trending products
            } else {
                searchResults.style.display = 'none'; // Hide if no results
                document.getElementById('products-container').style.display = 'block'; // Show trending products
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
} else {
    document.getElementById('search-results').style.display = 'none'; // Hide if no query
    document.getElementById('products-container').style.display = 'block'; // Show trending products
}
});


// view message




