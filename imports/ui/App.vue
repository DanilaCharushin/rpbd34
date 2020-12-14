<template>
    <div class="container">
        <header class="header">
            <h1>
                {{ users.length === 0 ? "Phonebook is empty" : "Phonebook users count: " + users.length }}
            </h1>
            <button class="btn btn-success" data-toggle="modal" data-target="#add-new-user-modal">Add new user</button>
        </header>
        <div class="search">
            <div class="form-check">
                <input class="form-check-input" type="checkbox" v-model="searchByFourDigits" value="true" id="searchByFourDigits" @change="search()">
                <label class="form-check-label" for="searchByFourDigits">
                    Search by the last 4 digits of the phone
                </label>
            </div>
            <div class="form-group">
                <input type="text" v-model="searchText" class="form-control" placeholder="type here for search users..." @input="search()">
            </div>
        </div>

        <hr>

        <div class="modal fade" id="add-new-user-modal" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Add new user</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form>
                            <div class="form-group">
                                <label for="name">Name</label>
                                <input type="text" v-model="newName" class="form-control" id="name" placeholder="ex: Freddie Mercury">
                            </div>
                            <div class="form-group">
                                <label for="address">Address</label>
                                <input type="text" v-model="newAddress" class="form-control" id="address" placeholder="ex: u. Pushkina, d. Kolotushkina">
                            </div>

                            <div class="form-group">
                                <label for="newHomeNumber">Home phone number</label>
                                <input type="tel" v-model="newHomeNumber" class="form-control" id="newHomeNumber">
                            </div>
                            <div class="form-group">
                                <label for="newWorkNumber">Work phone number</label>
                                <input type="tel" v-model="newWorkNumber" class="form-control" id="newWorkNumber">
                            </div>
                            <div class="form-group">
                                <label for="newMobileNumber">Mobile phone number</label>
                                <input type="tel" v-model="newMobileNumber" class="form-control" id="newMobileNumber">
                            </div>

                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                <button type="button" class="btn btn-success" data-dismiss="modal" @click="addNewUser">Save changes</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>


        <ul>
            <li
                v-for="user in users"
                :key="user._id"
            >
                <User :user="user"/>
            </li>
        </ul>
    </div>
</template>

<script>
import User from "./User";
import { Users } from "../api/users";
import { PhoneTypes } from "../api/phone_types";
import { Phones } from "../api/phones";

export default {
    components: {
        User
    },
    data() {
        return {
            newName: "",
            newAddress: "",
            newHomeNumber: "",
            newWorkNumber: "",
            newMobileNumber: "",
            searchText: "",
            searchByFourDigits: false,
            users: [],
            allUsers: []
        };
    },
    async created() {
        this.users = await Users.find({}).fetch();
    },
    methods: {
        addNewUser() {
            if (!this.newName) {
                return;
            }
            const mobile_phone_type = PhoneTypes.find({type: "mobile"}).fetch()[0]._id;
            const work_phone_type = PhoneTypes.find({type: "work"}).fetch()[0]._id;
            const home_phone_type = PhoneTypes.find({type: "home"}).fetch()[0]._id;
            let mobile_phone_id, work_phone_id, home_phone_id;
            let phone_ids_to_add_to_user = [];
            if (this.newMobileNumber) {
                mobile_phone_id = Phones.insert({number: this.newMobileNumber, type_id: mobile_phone_type});
                phone_ids_to_add_to_user.push(mobile_phone_id);
            }
            if (this.newWorkNumber) {
                work_phone_id = Phones.insert({number: this.newWorkNumber, type_id: work_phone_type});
                phone_ids_to_add_to_user.push(work_phone_id);
            }
            if (this.newHomeNumber) {
                home_phone_id = Phones.insert({number: this.newHomeNumber, type_id: home_phone_type});
                phone_ids_to_add_to_user.push(home_phone_id);
            }
            Users.insert({
                name: this.newName,
                address: this.newAddress,
                phone_ids: phone_ids_to_add_to_user
            });
            this.newAddress = "";
            this.newName = "";
            this.newMobileNumber = "";
            this.newWorkNumber = "";
            this.newHomeNumber = "";
        },
        search() {
            if (!this.searchText) {
                this.users = this.allUsers;
            } else {
                console.log(this.searchText);
                this.users = this.allUsers.filter(user => {
                    let phones = [];
                    for (const phone_id of user.phone_ids) {
                        const phone = Phones.find({_id: phone_id}).fetch()[0];
                        phones.push(phone);
                    }

                    if (this.searchByFourDigits) {
                        for (const phone of phones) {
                            console.log(phone.number.slice(-4));
                            if (phone.number.slice(-4).includes(this.searchText)) {
                                return true;
                            }
                        }
                    } else {
                        if (user.name.toLowerCase().includes(this.searchText.toLowerCase())
                            || user.address.toLowerCase().includes(this.searchText.toLowerCase())) {
                            return true;
                        }
                        for (const phone of phones) {
                            if (phone.number.includes(this.searchText)) {
                                return true;
                            }
                        }
                    }
                    return false;
                });
            }
        }
    },
    meteor: {
        async fetchUsers() {
            this.allUsers = await Users.find({}).fetch();
            this.users = Array.from(this.allUsers);
        }
    }
};
</script>
<style>
.header {
    display: flex;
    justify-content: space-between;
}
.search {
    margin: 2em 0;
}
</style>