float raceTime;
float prevTime;
float speed;
bool spawned = false;
bool inMap = false;
float pbTime;
float[] bestTimes;
float[] pbTimes;
float[] currTimes;
float[] bestSpeeds;
float[] pbSpeeds;
float[] currSpeeds;
string mapName;
string mapId;

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    class SOBMedal : UltimateMedalsExtended::IMedal {
        UltimateMedalsExtended::Config GetConfig() override { 
            UltimateMedalsExtended::Config config; 
            config.defaultName = 'Sum Of Best';
            config.icon = "\\$c0c" + Icons::Circle;
            return config;
        }
        uint medalTime;
        
        void UpdateMedal(const string &in uid) override {
            this.medalTime = sumTimes(bestTimes) * 1000;
        }

        bool HasMedalTime(const string &in uid) override {
            auto raceData = MLFeed::GetRaceData_V4();
            return bestTimes.Length == raceData.CPsToFinish;
        }
        uint GetMedalTime() override {
            this.UpdateMedal("");
            return this.medalTime;
        }
    }


#endif

void Main() {
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    UltimateMedalsExtended::AddMedal(SOBMedal());
#endif
}

void Update(float dt) {
    auto app = GetApp();
    auto playground = app.CurrentPlayground;
    if (playground is null) {
        if (inMap) {
            //print("----Left Map!----");
            SaveToFile(mapId);
            
            pbTime = 0;
            bestTimes = {};
            pbTimes = {};
            currTimes = {};
            bestSpeeds = {};
            pbSpeeds = {};
            currSpeeds = {};
            prevTime = -1.0f;
            raceTime = 0.0f;
            spawned = false;
        }
        inMap = false;
        return;
    };
    if (app.RootMap is null) return;
    mapName = app.RootMap.MapName;
    mapId = app.RootMap.IdName;
    if (!inMap) {
        //print("----Joined Map!----");
        LoadFromFile(mapId);
        inMap = true;
    }
    auto raceData = MLFeed::GetRaceData_V4();
    if (raceData is null) return;
    if (raceData.LocalPlayer is null) return;
    if (!raceData.LocalPlayer.IsSpawned) {
        if (spawned) {
            PlayerRetired();
        }
        return;
    };
    spawned = true;
    prevTime = raceTime;
    if (raceData.LocalPlayer.CpCount > 0) {
        UpdateTimes();
        if (prevTime != raceTime) {
            NewCheckpoint();
        }
        if (currTimes.Length == raceData.CPsToFinish) {
            Finish();
        }
    }
}

void UpdateBestData() {
    for (uint i = 0; i < currSpeeds.Length; i++) {
        if (currSpeeds[i] > bestSpeeds[i]) {
            bestSpeeds[i] = currSpeeds[i];
        }
        if (currTimes[i] < bestTimes[i]) {
            bestTimes[i] = currTimes[i];
        }
    }
}

void PlayerRetired() {
    print("Retired, clearing times.");

    UpdateBestData();

    currTimes = {};
    currSpeeds = {};
    prevTime = -1.0f;
    raceTime = 0.0f;
    spawned = false;
}

void NewCheckpoint() {
    currTimes.InsertLast(raceTime - prevTime);
    currSpeeds.InsertLast(speed);
    if (bestTimes.Length < currTimes.Length) {
        bestTimes.InsertLast(currTimes[bestTimes.Length]);
        bestSpeeds.InsertLast(currSpeeds[bestSpeeds.Length]);
    }
    //print("Added CP: " + (raceTime - prevTime) + "  " + speed);
    //print("Num CPs: " + currTimes.Length + " BCP: " + bestTimes.Length);
}

void UpdateTimes() {
    // Code taken from Checkpoint Time Overlay plugin
    auto app = cast<CTrackMania>(GetApp());
    auto loadMgr = app.LoadProgress;
    auto network = cast<CTrackManiaNetwork>(app.Network);

    if (network.ClientManiaAppPlayground !is null && network.ClientManiaAppPlayground.Playground !is null && network.ClientManiaAppPlayground.UILayers.Length > 0) {
        auto uilayers = network.ClientManiaAppPlayground.UILayers;
        for (uint i = 0; i < uilayers.Length; i++) {
            CGameUILayer@ curLayer = uilayers[i];
            int start = curLayer.ManialinkPageUtf8.IndexOf("<");
            int end = curLayer.ManialinkPageUtf8.IndexOf(">");

            if (start != -1 && end != -1) {
                auto manialinkname = curLayer.ManialinkPageUtf8.SubStr(start, end);
                if (manialinkname.Contains("UIModule_Race_Checkpoint")) {
                    auto raceTimeLabel = cast<CGameManialinkLabel@>(curLayer.LocalPage.GetFirstChild("label-race-time"));
                    raceTime = Text::ParseFloat(raceTimeLabel.Value.SubStr(3)) + 60*Text::ParseInt(raceTimeLabel.Value.SubStr(0,2));
                    auto state = VehicleState::ViewingPlayerState();
                    if (state is null) return;
                    speed = state.WorldVel.Length();
                    speed *= 3.6;
                }
            }
        }
    }
}

void Finish() {
    if (pbTime == 0 || raceTime < pbTime) {
        pbTimes = currTimes;
        pbTime = sumTimes(pbTimes);
        pbSpeeds = currSpeeds;
    }
}

float sumTimes(float[] times) {
    float sum = 0;
    for (uint i = 0; i < times.Length; i++) {
        sum += times[i];
    }
    return sum;
}
float sumDiffTimes(float[] times, float[] times2) {
    float sum = 0;
    for (int i = 0; i < Math::Min(times.Length, times2.Length); i++) {
        sum += times[i] - times2[i];
    }
    return sum;
}

void SaveToFile(const string &in mapUid) {
    if (mapUid == "") {
        print("Empty map uid when saving");
        return;
    }
    IO::File file;
    string filepath = IO::FromStorageFolder(mapUid + ".json");
    Json::Value json = Json::Object();

    json["pbTimes"] = pbTimes;
    json["bestTimes"] = bestTimes;
    json["pbSpeeds"] = pbSpeeds;
    json["bestSpeeds"] = bestSpeeds;
    json["pb"] = sumTimes(pbTimes);
    json["sob"] = sumTimes(bestTimes);

    file.Open(filepath, IO::FileMode::Write);
    file.Write(Json::Write(json));
    file.Close();
    print("Saved to file!");
}

void LoadFromFile(const string &in mapUid) {
    if (mapUid == "") {
        print("Empty map uid when loading");
        return;
    }
    IO::File file;
    string filePath = IO::FromStorageFolder(mapUid+".json");
    if (IO::FileExists(filePath)) {
        file.Open(filePath, IO::FileMode::Read);
        Json::Value json = Json::Parse(file.ReadToEnd());
        file.Close();

        pbTimes = Convert(json["pbTimes"]);
        bestTimes = Convert(json["bestTimes"]);
        pbSpeeds = Convert(json["pbSpeeds"]);
        bestSpeeds = Convert(json["bestSpeeds"]);
        pbTime = json["pb"];
        print("Loaded from file: " + mapUid);   
    }
}

float[] Convert(Json::Value value) {
    float[] output = {};
    for (uint i = 0; i < value.Length; i++) {
        output.InsertLast(value[i]);
    }
    return output;
}

void OnDisabled() {
    SaveToFile(mapId);
    inMap = false;
}
void OnDestroyed() {
    SaveToFile(mapId);
    inMap = false;
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    UltimateMedalsExtended::RemoveMedal("Sum Of Best");
#endif
}