string FormatTime(float time) {
    return Time::Format(int(time * 1000));
}
string FormatTimeDelta(float delta) {
    return ((delta >= 0) ? "+" : "") + FormatTime(delta);
}
string FormatSpeed(float speed) {
    return Text::Format("%.0f", speed);
}
string FormatSpeedDelta(float delta) {
    return ((delta >= 0) ? "+" : "") + FormatSpeed(delta);
}

void PushTimeDelta(float delta) {
    vec4 color;
    float scale = Math::Max(-1, Math::Min(1, (delta * 1000) / sc_timeScale));
    if (scale > 0) {
        color = lerpColor(sc_timePlusMin, sc_timePlusMax, scale);
    } else if (scale == 0){
        color = sc_timeEqual;
    } else {
        color = lerpColor(sc_timeMinusMin, sc_timeMinusMax, scale);
    }
    UI::PushStyleColor(UI::Col::Text, color);
    UI::Text(FormatTimeDelta(delta));
    UI::PopStyleColor();
}
void PushSpeedDelta(float delta) {
    vec4 color;
    float scale = Math::Max(-1, Math::Min(1, Math::Round(delta) / sc_speedScale));
    if (scale > 0) {
        color = lerpColor(sc_speedMinusMin, sc_speedMinusMax, scale);
    } else if (scale == 0){
        color = sc_speedEqual;
    } else {
        color = lerpColor(sc_speedPlusMin, sc_speedPlusMax, scale);
    }
    UI::PushStyleColor(UI::Col::Text, color);
    UI::Text(FormatSpeedDelta(delta));
    UI::PopStyleColor();
}

vec4 lerpColor(vec4 col1, vec4 col2, float t) {
    t = Math::Max(Math::Min(1, Math::Abs(t)), 0);
    return vec4(col1 * (1 - t) + col2 * t);
}

void Render() {
    if (!inMap) return;
    if (!sg_winEnabled) return;

    int numColumns = 1;
    if (sc_best) {
        numColumns++;
    }
    if (sc_bestDelta) {
        numColumns++;
    }
    if (sc_bestPBDelta) {
        numColumns++;
    }
    if (sc_PBDelta) {
        numColumns++;
    }
    if (sc_bestSpeed) {
        numColumns++;
    }
    if (sc_bestSpeedDelta) {
        numColumns++;
    }
    if (sc_bestPBSpeedDelta) {
        numColumns++;
    }
    if (sc_PBSpeedDelta) {
        numColumns++;
    }

    UI::Begin("Best CPs", UI::WindowFlags::NoDecoration | UI::WindowFlags::NoDocking | UI::WindowFlags::AlwaysAutoResize);
    //UI::Text("SOB: " + Time::Format(sumTimes(bestTimes)) + " PB: " + Time::Format(pbTime));
    if (sh_SOB) {
        UI::Text("SOB:");
        UI::SameLine();
        UI::Text(FormatTime(sumTimes(bestTimes)));
        UI::SameLine();
    }
    if (sh_BP) {
        UI::Text("Best Possible:");
        UI::SameLine(0, 5);
        float time = 0.;
        for (uint i = 0; i < bestTimes.Length; i++) {
            if (i < currTimes.Length) {
                time += currTimes[i];
            } else {
                time += bestTimes[i];
            }
        }
        UI::Text(FormatTime(time));
        UI::SameLine();
    }
    if (sh_PB) {
        UI::Text("PB:");
        UI::SameLine(0, 5);
        UI::Text(FormatTime(pbTime));
        UI::SameLine();
    }
    if (sh_bestDelta) {
        UI::Text("Best Delta:");
        UI::SameLine(0, 5);
        PushTimeDelta(sumDiffTimes(currTimes, bestTimes));
        UI::SameLine();
    }
    UI::NewLine();
    if (UI::BeginTable("cpData", numColumns)) {
        int currCP = currTimes.Length; 
        int offset = Math::Min(Math::Max(0, int(currCP + sg_lookAhead) - sg_maxRows), bestTimes.Length - Math::Min(sg_maxRows, bestTimes.Length));
        UI::TableNextColumn();
        
        UI::Text("Cp");
        for (int i = 0; i < Math::Min(sg_maxRows, bestTimes.Length); i++) {
            //UI::TableNextRow();
            UI::Text(""+(i+1 + offset));
        }
        UI::TableNextColumn();

        if (sc_best) {
            UI::Text("Best");
            for (int i = 0; i < Math::Min(sg_maxRows, bestTimes.Length - offset); i++) {
                //UI::TableNextRow();
                UI::Text(FormatTime(bestTimes[i + offset]));
            }
            UI::TableNextColumn();
        }
        if (sc_bestDelta) {
            UI::Text("B. Delta");
            for (int i = 0; i < Math::Min(sg_maxRows, currTimes.Length-offset); i++) {
                //UI::TableNextRow();
                //UI::Text(FormatTimeDelta(currTimes[i]-bestTimes[i]));
                PushTimeDelta(currTimes[i + offset]-bestTimes[i + offset]);
            }
            UI::TableNextColumn();
        }
        if (sc_bestPBDelta) {
            UI::Text("B.-PB Delta");
            for (int i = 0; i < Math::Min(sg_maxRows, pbTimes.Length); i++) {
                //UI::TableNextRow();
                PushTimeDelta(pbTimes[i + offset]-bestTimes[i + offset]);
            }
            UI::TableNextColumn();
        }
        if (sc_PBDelta) {
            UI::Text("PB Delta");
            for (int i = 0; i < Math::Min(sg_maxRows, Math::Min(currTimes.Length, pbTimes.Length)); i++) {
                //UI::TableNextRow();
                PushTimeDelta(pbTimes[i + offset]-currTimes[i + offset]);
            }
            UI::TableNextColumn();
        }
        if (sc_bestSpeed) {
            UI::Text("B. Speed");
            for (int i = 0; i < Math::Min(sg_maxRows, bestTimes.Length - offset); i++) {
                //UI::TableNextRow();
                UI::Text(FormatSpeed(bestSpeeds[i + offset]));
            }
            UI::TableNextColumn();
        }
        if (sc_bestSpeedDelta) {
            UI::Text("B. S. Delta");
            for (int i = 0; i < Math::Min(sg_maxRows, currTimes.Length - offset); i++) {
                //UI::TableNextRow();
                PushSpeedDelta(currSpeeds[i + offset]-bestSpeeds[i + offset]);
            }
            UI::TableNextColumn();
        }
        if (sc_bestPBSpeedDelta) {
            UI::Text("B.-PB S. Delta");
            for (int i = 0; i < Math::Min(sg_maxRows, pbSpeeds.Length); i++) {
                //UI::TableNextRow();
                PushSpeedDelta(pbSpeeds[i + offset]-bestSpeeds[i + offset]);
            }
            UI::TableNextColumn();
        }
        if (sc_PBSpeedDelta) {
            UI::Text("PB S. Delta");
            for (int i = 0; i < Math::Min(sg_maxRows, Math::Min(currSpeeds.Length, pbSpeeds.Length)); i++) {
                //UI::TableNextRow();
                PushSpeedDelta(currSpeeds[i + offset]-pbSpeeds[i + offset]);
            }
            UI::TableNextColumn();
        }
        UI::EndTable();
    }
    UI::End();
}