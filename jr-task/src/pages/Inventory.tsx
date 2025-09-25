import Ex_Data from "../ex_data/products.json";

export default function Inventory() {
    return (
        <>
            <span className="filters">
                <form>
                    <label htmlFor="input-Search"></label>
                    <input type="search" id="input-Search" name="query" placeholder="Search:"/>
                </form>

                <label htmlFor="category">Category</label>
                <select name="Category" id="category">
                    <option>All</option>
                    <option>Electronics</option>
                    <option>Wearables</option>
                    <option>Accessories</option>
                </select>
                
                <label htmlFor="status">Status</label>
                <select name="Status" id="status">
                    <option>All</option>
                    <option>In Stock</option>
                    <option>Low Stock</option>
                    <option>Out of Stock</option>
                </select>
            </span>

            {Ex_Data.map((item, index) => (
                <div key={index}>
                    <img src={item.product_img} alt={item.product} />
                    <p>{item.product}</p>
                    <p>${item.price}</p>
                    <p>{item.quantity}</p>
                    <p>{item.category}</p>
                    <button>Add to Cart</button>
                </div>
            ))}
        </>
    );
}