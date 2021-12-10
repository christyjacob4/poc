import * as React from "react";
import { _SERVICE } from "../../../declarations/dataResearch/dataResearch.did";
import { Button, Text } from "@adobe/react-spectrum";
import ImageProfile from "@spectrum-icons/workflow/ImageProfile";
import { useHistory } from "react-router-dom";

function Home() {
  const history = useHistory();

  return (
    <section>
      <h2>Data Research</h2>
      <p>
        Welcome to Data Research!
      </p>
    </section>
  );
}

export default React.memo(Home);
