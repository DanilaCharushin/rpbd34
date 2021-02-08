<template>
    <div class="user">
        <div class="user-info">
            <span>{{user.name}}</span>
            <span>{{user.address}}</span>
            <div class="btn-group" role="group">
                <button :id="'phones' + user._id" type="button" class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Phones
                </button>
                <div class="dropdown-menu">
                    <a :href="'tel:' + phone.number" class="phone" v-for="phone in getPhones" :key="phone._id">
                        <span>{{phone.number}}</span>
                        <span class="material-icons">{{getPhoneTypeIcon(phone)}}</span>
                    </a>
                </div>
            </div>
        </div>
        <div class="user-actions">
            <span class="btn btn-outline-primary" data-toggle="modal" @click="newPhoneIds = user.phone_ids" :data-target="'#edit-modal' + user._id">Edit</span>
            <span class="btn btn-outline-danger" @click="removeUser">Remove</span>
        </div>
        <div class="modal fade" :id="'edit-modal' + user._id" tabindex="-1" role="dialog" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Edit user "{{user.name}}"</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form>
                            <div class="form-group">
                                <label for="name">Name</label>
                                <input type="text" v-model="newName" class="form-control" id="name" :placeholder="user.name">
                            </div>
                            <div class="form-group">
                                <label for="address">Address</label>
                                <input type="text" v-model="newAddress" class="form-control" id="address" :placeholder="user.address">
                            </div>

                            <div class="phone" v-for="(phone, i) in getEditPhones" :key="phone._id">
                                <input type="tel" v-model="phone.number" class="form-control" :id="phone._id" :placeholder="phone.number">
                                <div class="form-check form-check-inline phone-type-radio" v-for="type in getPhoneTypes" :key="type._id">
                                    <input
                                        class="form-check-input"
                                        v-model="phone.type"
                                        type="radio"
                                        :name="'phone-type' + phone._id"
                                        :id="phone._id + type._id"
                                        :value="type.type"
                                    >
                                    <label class="form-check-label" :for="phone._id + type._id">{{type.type}}</label>
                                </div>
                                <span class="btn btn-danger" @click="removePhone(phone._id)">X</span>
                            </div>

                            <div class="phone">
                                <input
                                    type="tel"
                                    v-model="newPhoneNumber"
                                    class="form-control"
                                    :id="'newPhoneNumber' + user._id"
                                    placeholder="add new phone">
                                <div class="form-check form-check-inline phone-type-radio" v-for="type in getPhoneTypes" :key="type._id">
                                    <input
                                        class="form-check-input"
                                        v-model="newPhoneType"
                                        type="radio"
                                        :name="'phone-type' + user._id"
                                        :id="user._id + type._id"
                                        :value="type.type"
                                    >
                                    <label class="form-check-label" :for="user._id + type._id">{{type.type}}</label>
                                </div>
                            </div>

                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                <button type="button" class="btn btn-success" data-dismiss="modal" @close="alert(1)" @click="updateUser">Save changes</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { Users } from "../api/users";
import { PhoneTypes } from "../api/phone_types";
import { Phones } from "../api/phones";

export default {
    name: "User",
    props: ["user"],
    data() {
        return {
            edit: false,
            newName: this.user.name,
            newAddress: this.user.address,
            newPhoneIds: this.user.phone_ids,
            newPhoneNumber: "",
            newPhoneType: "mobile"
        }
    },
    methods: {
        getPhoneTypeIcon(phone) {
            return phone.type === "mobile" ? "phone_iphone" : phone.type;
        },
        updateUser() {
            if (!this.newName) {
                return;
            }

            let phone_ids = this.newPhoneIds;
            let phone_ids_to_remove = [];

            for (const phone_id of this.user.phone_ids) {
                if (!phone_ids.includes(phone_id)) {
                    phone_ids_to_remove.push(phone_id);
                }
            }
            for (const phone_id of phone_ids_to_remove) {
                Phones.remove(phone_id);
            }

            for (const phone of this.getEditPhones) {
                const type_id = PhoneTypes.find({type: phone.type}).fetch()[0]._id;
                Phones.update(phone._id, {
                    $set:{
                        type_id: type_id,
                        number: phone.number
                    }
                });
            }

            if (this.newPhoneNumber) {
                const phoneTypeId = PhoneTypes.find({type: this.newPhoneType}).fetch()[0]._id;
                const newPhoneId = Phones.insert({
                    number: this.newPhoneNumber,
                    type_id: phoneTypeId
                });
                phone_ids.push(newPhoneId);
                this.newPhoneNumber = "";
                this.newPhoneType = "mobile";
            }
            Users.update(this.user._id, {
                $set: {
                    name: this.newName,
                    address: this.newAddress,
                    phone_ids: phone_ids
                }
            });
            // this.newName = this.user.name;
            // this.newAddress = this.user.address;
        },
        removeUser() {
            for (const phone_id of this.user.phone_ids) {
                Phones.remove(phone_id);
            }
            Users.remove(this.user._id);
        },
        removePhone(_id) {
            this.newPhoneIds = this.newPhoneIds.filter(id => id !== _id);
        }
    },
    meteor: {
        getPhones() {
            let phones = [];
            for (const phone_id of this.user.phone_ids) {
                const phone = Phones.find({_id: phone_id}).fetch()[0];
                const phoneType = PhoneTypes.find({_id: phone.type_id}).fetch()[0];
                phones.push({_id: phone._id, number: phone.number, type: phoneType.type});
            }
            return phones;
        },
        getEditPhones() {
            let phones = [];
            for (const phone_id of this.newPhoneIds) {
                const phone = Phones.find({_id: phone_id}).fetch()[0];
                const phoneType = PhoneTypes.find({_id: phone.type_id}).fetch()[0];
                phones.push({_id: phone._id, number: phone.number, type: phoneType.type, type_id: phone.type_id});
            }
            return phones;
        },
        getPhoneTypes() {
            return PhoneTypes.find({}).fetch();
        }
    }
}
</script>

<style>
.user {
    display: flex;
    justify-content: space-between;
}

.user-info {
    flex-basis: 80%;
    display: flex;
    justify-content: space-between;
}

.dropdown-menu {
    width: 150px;
    left: -30px !important;
}
.phone {
    display: flex;
    justify-content: space-between;
    padding: 0.5em;
}
.phone-type-radio {
    margin: 0 0.5em;
}
</style>