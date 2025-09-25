import users from "../ex_data/user.json";

export default function Users() {
    return (
        <>
            <span className="flex justify-between items-center mb-4">
                <form>
                    <label htmlFor="input-Search"></label>
                    <input
                        type="search"
                        id="input-Search"
                        name="query"
                        placeholder="Search..."
                        className="border px-3 py-1 rounded"
                    />
                </form>

                <label htmlFor="user"></label>
                <select
                    name="Category"
                    id="category"
                    className="border px-3 py-1 rounded"
                >
                    <option>All User</option>
                    <option>Electronics</option>
                    <option>Wearables</option>
                    <option>Accessories</option>
                </select>
            </span>

            <div>
                {/* Table Header */}
                <div>
                    <h4>Username</h4>
                    <h4>Email</h4>
                    <h4>User Role</h4>
                    <h4>Action</h4>
                </div>

                {/* Table Rows */}
                {users.map((user, index) => (
                    <div
                        key={index}
                    >
                        <p>{user.username}</p>
                        <p>{user.email}</p>
                        <p>{user.user_role}</p>
                        <p className="flex gap-2">
                            <button className="text-blue-500">✏️</button>
                            <button className="text-red-500">🗑️</button>
                        </p>
                    </div>
                ))}
            </div>
        </>
    );
}
