import React, { Component } from "react";
import web3 from "./web3";
import "./App.css";
import { Route } from "react-router-dom";

import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Typography";
import Grid from "@material-ui/core/Grid";

// Import Contracts
import StakeholderRegistration from "./contracts/StakeholderRegistration";

// Import Home Pages
import HomeIssuer from "./pages/HomeIssuer";
import HomeStakeholder from "./pages/HomeStakeholder";
import HomeNone from "./pages/HomeNone";

// Import Forms
import PurchaseForm from "./pages/components/PurchaseForm";
import CreateStakeholder from "./pages/components/CreateStakeholder";

class App extends Component {
    state = {
        account: "0x000",
        userType: 0,
    };

    async componentDidMount() {
        console.log(window.env.CONTRACT_STAKEHOLDER_REGISTRATION);

        if (window.ethereum) {
            window.ethereum.enable();
            const accounts = await web3.eth.getAccounts();

            this.setState({ account: accounts[0] });
            await this.getUserType();
        } else {
            alert("ERROR! WEB 3 NOT FOUND!");
        }
    }

    // GET type of user using the account address
    async getUserType() {
        console.log(StakeholderRegistration);
        let user = await StakeholderRegistration.methods.Stakeholders(this.state.account).call();
        // let user = false;
        // console.log(user);
        if (user) this.setState({ userType: 2 });
        else if (!user) {
            user = await StakeholderRegistration.methods.Issuer().call();
            console.log("INT", user);
            if (user === this.state.account) this.setState({ userType: 1 });
            else this.setState({ userType: 0 });
        }
    }

    render() {
        return (
            <div className="App">
                <AppBar position="static">
                    <Toolbar>
                        <Grid container spacing={3}>
                            <Grid item xs={3}>
                                <Typography variant="h6">Waste Managment Console</Typography>
                            </Grid>
                            <Grid item xs={9}>
                                <Typography variant="h6" align="right">
                                    Address: {this.state.account}.
                                </Typography>
                            </Grid>
                        </Grid>
                    </Toolbar>
                </AppBar>
                <Route
                    exact
                    path="/"
                    component={
                        this.state.userType === 1 ? HomeIssuer : this.state.userType === 2 ? HomeStakeholder : HomeNone
                    }
                ></Route>
                <Route exact path="/purchase" component={PurchaseForm}></Route>
                <Route exact path="/create-stakeholder" component={CreateStakeholder}></Route>
            </div>
        );
    }
}

export default App;
